// Created by Alex Yaro on 2023-04-07.

import Collections
import Combine
import Foundation

protocol PlaybackQueueType {
    associatedtype State: PlaybackQueueState
    typealias StateWithContext = (state: State, context: PlaybackQueueStateContext?)

    var source: AnyPublisher<ContentObject?, Never> { get }
    var stateWithContext: AnyPublisher<StateWithContext, Never> { get }
    var state: AnyPublisher<State, Never> { get }
    var hasPreviousItem: AnyPublisher<Bool, Never> { get }
    var hasNextItem: AnyPublisher<Bool, Never> { get }

    func load(with content: ContentObject)
    func load(with songs: [Song], source: ContentObject?)
    func addToQueue(_ song: Song)

    func goToNextItem()
    func goToPreviousItem()
    func goToItem(atIndex index: PlaybackQueueIndex, emptyUserQueueIfUpNextIndex: Bool)

    @discardableResult
    func moveItem(from fromIndex: PlaybackQueueIndex, to toIndex: PlaybackQueueIndex) -> Bool
    func moveItemsToQueue(at indices: [PlaybackQueueIndex])
    func removeItems(at indices: [PlaybackQueueIndex])
}

extension PlaybackQueueType {
    var state: AnyPublisher<State, Never> {
        stateWithContext.map(\.state).eraseToAnyPublisher()
    }
    var hasPreviousItem: AnyPublisher<Bool, Never> {
        state
            .map { $0.history.count > 0 }
            .eraseToAnyPublisher()
    }
    var hasNextItem: AnyPublisher<Bool, Never> {
        state
            .map { $0.userQueue.count + $0.upNext.count > 0 }
            .eraseToAnyPublisher()
    }

    func goToItem(atIndex index: PlaybackQueueIndex) {
        goToItem(atIndex: index, emptyUserQueueIfUpNextIndex: true)
    }
}

final class PlaybackQueue: PlaybackQueueType {
    typealias Item = PlaybackQueueItem

    struct Dependencies {
        let contentService: ContentServiceType
    }

    // MARK: - Public Interface

    var source: AnyPublisher<ContentObject?, Never> {
        sourceSubject.eraseToAnyPublisher()
    }
    var stateWithContext: AnyPublisher<StateWithContext, Never> {
        _stateWithContextSubject.prepend((state: currentState, context: nil)).eraseToAnyPublisher()
    }

    // MARK: - Private State

    private let sourceSubject = CurrentValueSubject<ContentObject?, Never>(nil)

    /// Don't emit to this directly; instead, update `currentState`!
    private let _stateWithContextSubject = PassthroughSubject<StateWithContext, Never>()
    private var contextForNextStateChange: PlaybackQueueStateContext?
    private var currentState: State = .init() {
        didSet {
            _stateWithContextSubject.send((state: currentState, context: contextForNextStateChange))
            contextForNextStateChange = nil
        }
    }

    private let dependencies: Dependencies
    private var dataLoadCancellable: AnyCancellable?

    // MARK: - Initializer

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func load(with content: ContentObject) {
        guard sourceSubject.value != content else { return }
        sourceSubject.send(content)

        dataLoadCancellable?.cancel()
        dataLoadCancellable = dependencies.contentService
            .fetchSongs(for: content)
            .sink(receiveCompletion: { [weak sourceSubject] in
                if case .failure = $0 {
                    sourceSubject?.send(nil)
                }
            }, receiveValue: { [weak self] in
                guard let self else { return }
                currentState.load(with: $0)
            })
    }

    func load(with songs: [Song], source: ContentObject?) {
        sourceSubject.send(source)
        currentState.load(with: songs)
    }

    func addToQueue(_ song: Song) {
        let item = Item(song: song, isUserQueueItem: true)
        currentState.userQueue.append(item)
    }

    // TODO: func clearQueue()

    func goToNextItem() {
        var state = currentState

        guard let nextItem = state.userQueue.popFirst() ?? state.upNext.popFirst() else {
            return
        }

        var removedItem: PlaybackQueueItem?
        if let activeItem = state.activeItem {
            if !activeItem.isUserQueueItem {
                state.history.append(activeItem)
            } else {
                removedItem = activeItem
            }
        }
        state.activeItem = nextItem

        contextForNextStateChange = .movedToNextItem(removedItem: removedItem)
        currentState = state
    }

    func goToPreviousItem() {
        var state = currentState

        guard let previousItem = state.history.popLast() else {
            return
        }

        var removedItem: PlaybackQueueItem?
        if let activeItem = state.activeItem {
            if !activeItem.isUserQueueItem {
                state.upNext.prepend(activeItem)
            } else {
                removedItem = activeItem
            }
        }
        state.activeItem = previousItem

        contextForNextStateChange = .movedToPreviousItem(removedItem: removedItem)
        currentState = state
    }

    func goToItem(atIndex index: PlaybackQueueIndex, emptyUserQueueIfUpNextIndex: Bool) {
        var state = currentState

        guard index.isValid(for: state) else {
            return
        }

        switch index {
        case .history(let offset):
            if let activeItem = state.activeItem, !activeItem.isUserQueueItem {
                state.upNext.prepend(activeItem)
            }
            let itemsToMoveToUpNext = (state.history.count - offset)-1

            for _ in 0..<itemsToMoveToUpNext {
                state.upNext.prepend(state.history.removeLast())
            }

            state.activeItem = state.history.removeLast()

        case .activeItem:
            // no-op
            return

        case .userQueue(let offset):
            if let activeItem = state.activeItem, !activeItem.isUserQueueItem {
                state.history.append(activeItem)
            }
            state.userQueue.removeFirst(offset)
            state.activeItem = state.userQueue.removeFirst()

        case .upNext(let offset):
            if let activeItem = state.activeItem, !activeItem.isUserQueueItem {
                state.history.append(activeItem)
            }
            if emptyUserQueueIfUpNextIndex {
                state.userQueue.removeAll()
            }
            for _ in 0..<offset {
                state.history.append(state.upNext.removeFirst())
            }
            state.activeItem = state.upNext.removeFirst()
        }

        currentState = state
    }

    @discardableResult
    func moveItem(from fromIndex: PlaybackQueueIndex, to toIndex: PlaybackQueueIndex) -> Bool {
        var state = currentState

        guard
            fromIndex.isValid(for: state),
            toIndex.isValid(for: state, forInsertion: true),
            fromIndex != .activeItem,
            toIndex != .activeItem
        else {
            return false
        }

        var movingItem: PlaybackQueueItem

        switch fromIndex {
        case .history(let offset):
            movingItem = state.history.remove(at: offset)
        case .activeItem:
            return false
        case .userQueue(let offset):
            movingItem = state.userQueue.remove(at: offset)
            movingItem.isUserQueueItem = false
        case .upNext(let offset):
            movingItem = state.upNext.remove(at: offset)
        }

        switch toIndex {
        case .history(let offset):
            state.history.insert(movingItem, at: offset)
        case .activeItem:
            return false
        case .userQueue(let offset):
            movingItem.isUserQueueItem = true
            state.userQueue.insert(movingItem, at: offset)
        case .upNext(let offset):
            state.upNext.insert(movingItem, at: offset)
        }

        currentState = state
        return true
    }

    func moveItemsToQueue(at indices: [PlaybackQueueIndex]) {
        guard var (state, removedItems) = stateForRemovedItems(at: indices) else {
            return
        }
        state.userQueue.append(contentsOf: removedItems.map {
            var updatedItem = $0
            updatedItem.isUserQueueItem = true
            return updatedItem
        })
        currentState = state
    }

    func removeItems(at indices: [PlaybackQueueIndex]) {
        let removeResult = stateForRemovedItems(at: indices)
        if let (state, _) = removeResult {
            currentState = state
        }
    }

    private func stateForRemovedItems(at indices: [PlaybackQueueIndex]) -> (State, removedItems: [PlaybackQueueItem])? {
        var state = currentState

        var indices = indices
        indices.sort(by: >)

        var historyIndices = [Int]()
        var userQueueIndices = [Int]()
        var upNextIndices = [Int]()

        var removedItems = [PlaybackQueueItem]()
        removedItems.reserveCapacity(indices.count)

        for index in indices {
            guard index.isValid(for: state) else {
                continue
            }
            switch index {
            case .history(let index):
                historyIndices.append(index)
            case .activeItem:
                continue
            case .userQueue(let index):
                userQueueIndices.append(index)
            case .upNext(let index):
                upNextIndices.append(index)
            }

            if let itemBeingRemoved = state[itemAt: index] {
                removedItems.append(itemBeingRemoved)
            }
        }

        guard !(historyIndices.isEmpty && userQueueIndices.isEmpty && upNextIndices.isEmpty) else {
            return nil
        }

        state.history.remove(atOffsets: IndexSet(historyIndices))
        state.userQueue.remove(atOffsets: IndexSet(userQueueIndices))
        state.upNext.remove(atOffsets: IndexSet(upNextIndices))

        return (state, removedItems: removedItems.reversed())
    }
}

extension PlaybackQueue {
    struct State: PlaybackQueueState {

        var history: [Item]
        var activeItem: Item?
        var userQueue: Deque<Item>
        var upNext: Deque<Item>

        init() {
            history = []
            userQueue = .init(minimumCapacity: 20)
            upNext = .init()
        }

        mutating func load(with songs: [Song]) {
            history = []
            activeItem = songs[safe: 0].map { .init(song: $0) }
            if songs.count > 1 {
                upNext = Deque<Item>(songs[1...].map { .init(song: $0) })
            } else {
                upNext = Deque<Item>(minimumCapacity: 1)
            }
        }
    }
}

extension PlaybackQueue.Dependencies {
    static func live() -> Self {
        .init(
            contentService: ContentService()
        )
    }
}
