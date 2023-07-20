// Created by Alex Yaro on 2023-04-22.

@testable import Topsify
import Combine
import XCTest
import TestHelpers

final class PlaybackQueueIndexTests: XCTestCase {
    typealias MockState = MockPlaybackQueue.State

    // MARK: - fromRawIndex

    func test_fromRawIndex_atBoundaries() {
        let state = MockState(
            history: .mock(count: 2),
            activeItem: .init(song: .mock()),
            userQueue: .mock(count: 4),
            upNext: .mock(count: 3)
        )

        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: -1, using: state), nil)

        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: 0, using: state), .history(0))
        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: 1, using: state), .history(1))

        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: 2, using: state), .activeItem)

        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: 3, using: state), .userQueue(0))
        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: 6, using: state), .userQueue(3))

        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: 7, using: state), .upNext(0))
        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: 9, using: state), .upNext(2))

        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: 10, using: state), nil)
    }

    func test_fromRawIndex_whenEmptyHistory() {
        let state = MockState(
            history: [],
            activeItem: .init(song: .mock()),
            userQueue: .mock(count: 5),
            upNext: .mock(count: 4)
        )

        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: 0, using: state), .activeItem)
    }

    func test_fromRawIndex_whenNoActiveItem() {
        let state = MockState(
            history: .mock(count: 2),
            activeItem: nil,
            userQueue: .mock(count: 4),
            upNext: .mock(count: 4)
        )

        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: 1, using: state), .history(1))
        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: 2, using: state), .userQueue(0))
    }

    func test_fromRawIndex_whenEmptyUserQueue() {
        let state = MockState(
            history: .mock(count: 4),
            activeItem: .init(song: .mock()),
            userQueue: [],
            upNext: .mock(count: 5)
        )

        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: 4, using: state), .activeItem)
        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: 5, using: state), .upNext(0))
    }

    func test_fromRawIndex_whenEmptyUpNext() {
        let state = MockState(
            history: .mock(count: 4),
            activeItem: .init(song: .mock()),
            userQueue: .mock(count: 5),
            upNext: []
        )

        XCTAssertEqual(PlaybackQueueIndex.from(rawIndex: 9, using: state), .userQueue(4))
    }

    // MARK: - isValid

    func test_isValid_forEmptyState() {
        let state = MockState()

        XCTAssertFalse(PlaybackQueueIndex.history(0).isValid(for: state))
        XCTAssertFalse(PlaybackQueueIndex.activeItem.isValid(for: state))
        XCTAssertFalse(PlaybackQueueIndex.userQueue(0).isValid(for: state))
        XCTAssertFalse(PlaybackQueueIndex.upNext(0).isValid(for: state))

        XCTAssertTrue(PlaybackQueueIndex.history(0).isValid(for: state, forInsertion: true))
        XCTAssertFalse(PlaybackQueueIndex.activeItem.isValid(for: state))
        XCTAssertTrue(PlaybackQueueIndex.userQueue(0).isValid(for: state, forInsertion: true))
        XCTAssertTrue(PlaybackQueueIndex.upNext(0).isValid(for: state, forInsertion: true))
    }

    func test_isValid_usingHistoryIndex() {
        let state = MockState(
            history: .mock(count: 4)
        )

        XCTAssertFalse(PlaybackQueueIndex.history(-1).isValid(for: state))
        XCTAssertTrue(PlaybackQueueIndex.history(0).isValid(for: state))
        XCTAssertTrue(PlaybackQueueIndex.history(3).isValid(for: state))
        XCTAssertFalse(PlaybackQueueIndex.history(4).isValid(for: state))

        XCTAssertFalse(PlaybackQueueIndex.history(-1).isValid(for: state, forInsertion: true))
        XCTAssertTrue(PlaybackQueueIndex.history(0).isValid(for: state, forInsertion: true))
        XCTAssertTrue(PlaybackQueueIndex.history(4).isValid(for: state, forInsertion: true))
        XCTAssertFalse(PlaybackQueueIndex.history(5).isValid(for: state, forInsertion: true))
    }

    func test_isValid_usingActiveItemIndex() {
        let state = MockState(
            activeItem: .init(song: .mock())
        )

        XCTAssertTrue(PlaybackQueueIndex.activeItem.isValid(for: state))
        XCTAssertFalse(PlaybackQueueIndex.activeItem.isValid(for: state, forInsertion: true))
    }

    func test_isValid_usingUserQueueIndex() {
        let state = MockState(
            userQueue: .mock(count: 4)
        )

        XCTAssertFalse(PlaybackQueueIndex.userQueue(-1).isValid(for: state))
        XCTAssertTrue(PlaybackQueueIndex.userQueue(0).isValid(for: state))
        XCTAssertTrue(PlaybackQueueIndex.userQueue(3).isValid(for: state))
        XCTAssertFalse(PlaybackQueueIndex.userQueue(4).isValid(for: state))

        XCTAssertFalse(PlaybackQueueIndex.userQueue(-1).isValid(for: state, forInsertion: true))
        XCTAssertTrue(PlaybackQueueIndex.userQueue(0).isValid(for: state, forInsertion: true))
        XCTAssertTrue(PlaybackQueueIndex.userQueue(4).isValid(for: state, forInsertion: true))
        XCTAssertFalse(PlaybackQueueIndex.userQueue(5).isValid(for: state, forInsertion: true))
    }

    func test_isValid_usingUpNextIndex() {
        let state = MockState(
            upNext: .mock(count: 4)
        )

        XCTAssertFalse(PlaybackQueueIndex.upNext(-1).isValid(for: state))
        XCTAssertTrue(PlaybackQueueIndex.upNext(0).isValid(for: state))
        XCTAssertTrue(PlaybackQueueIndex.upNext(3).isValid(for: state))
        XCTAssertFalse(PlaybackQueueIndex.upNext(4).isValid(for: state))

        XCTAssertFalse(PlaybackQueueIndex.upNext(-1).isValid(for: state, forInsertion: true))
        XCTAssertTrue(PlaybackQueueIndex.upNext(0).isValid(for: state, forInsertion: true))
        XCTAssertTrue(PlaybackQueueIndex.upNext(4).isValid(for: state, forInsertion: true))
        XCTAssertFalse(PlaybackQueueIndex.upNext(5).isValid(for: state, forInsertion: true))
    }
}

private extension Array where Element == PlaybackQueueItem {

    static func mock(count: Int) -> Self {
        Swift.Array(repeating: (), count: count).map { PlaybackQueueItem(song: .mock()) }
    }
}

private struct State: PlaybackQueueState {
    var history: Array<Topsify.PlaybackQueueItem>
    var activeItem: Topsify.PlaybackQueueItem?
    var userQueue: Array<Topsify.PlaybackQueueItem>
    var upNext: Array<Topsify.PlaybackQueueItem>
}
