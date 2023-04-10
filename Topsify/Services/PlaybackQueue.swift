// Created by Alex Yaro on 2023-04-07.

import Collections
import Combine
import Foundation

final class PlaybackQueue {

    struct Item: Identifiable, Equatable {
        let id: UUID
        let song: Song

        init(id: UUID = .init(), song: Song) {
            self.id = id
            self.song = song
        }
    }

    struct Dependencies {
        let contentService: ContentServiceType
    }

    // MARK: - Public Interface

    var source: AnyPublisher<ContentObject?, Never> {
        sourceSubject.eraseToAnyPublisher()
    }
    var state: AnyPublisher<some PlaybackQueueState, Never> {
        stateSubject.eraseToAnyPublisher()
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
            }, receiveValue: { [weak stateSubject] in
                stateSubject?.send(.init(from: $0))
            })
    }
}

protocol PlaybackQueueState {
    associatedtype HistoryCollection: Collection<PlaybackQueue.Item>
    associatedtype UserQueueCollection: Collection<PlaybackQueue.Item>
    associatedtype UpNextCollection: Collection<PlaybackQueue.Item>

    var history: HistoryCollection { get }
    var activeItem: PlaybackQueue.Item? { get }
    var userQueue: UserQueueCollection { get }
    var upNext: UpNextCollection { get }

    var count: Int { get }
    var activeItemIndex: Int { get }

    subscript (itemAt index: Int) -> PlaybackQueue.Item? { get }
}

private extension PlaybackQueue {
    struct State: PlaybackQueueState {
        var history: [Item] = []
        var activeItem: Item?
        var userQueue: Deque<Item> = Deque<Item>(minimumCapacity: 20)
        var upNext: Deque<Item> = Deque<Item>(minimumCapacity: 80)

        init(from songs: [Song] = []) {
            history = []
            activeItem = songs[safe: 0].map { .init(song: $0) }
            userQueue = Deque<Item>(minimumCapacity: 20)
            if songs.count > 1 {
                upNext = Deque<Item>(songs[1...].map { .init(song: $0) })
            } else {
                upNext = Deque<Item>(minimumCapacity: 1)
            }
        }

        var count: Int {
            history.count +
            (activeItem != nil ? 1 : 0) +
            userQueue.count +
            upNext.count
        }

        var activeItemIndex: Int {
            activeItem != nil ? history.count : -1
        }

        subscript (itemAt index: Int) -> Item? {
            var index = index
            if index < history.count {
                return history[safe: index]
            }
            index -= history.count
            if index == 0 {
                return activeItem
            }
            index -= 1
            // TODO: finish cases
            return nil
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
