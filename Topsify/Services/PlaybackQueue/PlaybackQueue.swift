// Created by Alex Yaro on 2023-04-07.

import Collections
import Combine
import Foundation

protocol PlaybackQueueType {
    associatedtype State: PlaybackQueueState

    var source: AnyPublisher<ContentObject?, Never> { get }
    var state: AnyPublisher<State, Never> { get }
    var hasPreviousItem: AnyPublisher<Bool, Never> { get }
    var hasNextItem: AnyPublisher<Bool, Never> { get }

    func load(with content: ContentObject)
    func load(with songs: [Song], source: ContentObject?)
    func addToQueue(_ song: Song)

    func goToNextItem()
    func goToPreviousItem()
    func goToItem(atIndex index: PlaybackQueueIndex)
}

extension PlaybackQueueType {
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
    var state: AnyPublisher<State, Never> {
        stateSubject.eraseToAnyPublisher()
    }

    // MARK: - Private State

    private let sourceSubject = CurrentValueSubject<ContentObject?, Never>(nil)
    private let stateSubject = CurrentValueSubject<State, Never>(.init())

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
                var state = stateSubject.value
                state.load(with: $0)
                stateSubject.send(state)
            })
    }

    func load(with songs: [Song], source: ContentObject?) {
        sourceSubject.send(source)
        var state = stateSubject.value
        state.load(with: songs)
        stateSubject.send(state)
    }

    func goToNextItem() {
        var state = stateSubject.value

        guard let nextItem = state.userQueue.popFirst() ?? state.upNext.popFirst() else {
            return
        }

        if let activeItem = state.activeItem, !activeItem.isUserQueueItem {
            state.history.append(activeItem)
        }
        state.activeItem = nextItem

        stateSubject.send(state)
    }

    func goToPreviousItem() {
        var state = stateSubject.value

        guard let previousItem = state.history.popLast() else {
            return
        }

        if let activeItem = state.activeItem, !activeItem.isUserQueueItem {
            state.upNext.prepend(activeItem)
        }
        state.activeItem = previousItem

        stateSubject.send(state)
    }

    func goToItem(atIndex index: PlaybackQueueIndex) {
        var state = stateSubject.value

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
            for _ in 0..<offset {
                state.history.append(state.upNext.removeFirst())
            }
            state.activeItem = state.upNext.removeFirst()
        }

        stateSubject.send(state)
    }

    func addToQueue(_ song: Song) {
        var state = stateSubject.value
        let item = Item(song: song, isUserQueueItem: true)
        state.userQueue.append(item)
        stateSubject.send(state)
    }

    // TODO: func clearQueue()
    // TODO: func goToItem(atUserQueueIndex index: Int)
    // TODO: func goToItem(atUpNextIndex index: Int)
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
