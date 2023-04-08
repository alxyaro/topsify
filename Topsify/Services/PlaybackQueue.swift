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

    private let stateSubject = CurrentValueSubject<State, Never>(.init(
        history: [],
        userQueue: .init(),
        upNext: .init()
    ))

    // MARK: - Initializer

    init(dependencies: Dependencies) {

    }

    func load(with song: Song) {
        sourceSubject.send(.song(song))
        stateSubject.send(State(
            activeItem: .init(song: song)
        ))
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
            nil
        }
    }
}

extension PlaybackQueue.Dependencies {
    static func live() -> Self {
        .init()
    }
}
