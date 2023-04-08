// Created by Alex Yaro on 2023-04-07.

@testable import Topsify
import Combine
import XCTest
import TestHelpers

final class PlaybackQueueTests: XCTestCase {

    func test_initialState() {
        let sut = PlaybackQueue(dependencies: .mock())

        let source = TestSubscriber.subscribe(to: sut.source)
        let state = TestSubscriber.subscribe(to: sut.state)
        let hasPreviousItem = TestSubscriber.subscribe(to: sut.hasPreviousItem)
        let hasNextItem = TestSubscriber.subscribe(to: sut.hasNextItem)

        XCTAssertEqual(source.pollValues(), [nil])

        assertState(
            state,
            history: [],
            activeItemSong: nil,
            userQueue: [],
            upNext: []
        ) { state in
            XCTAssertEqual(state[itemAt: -1], nil)
            XCTAssertEqual(state[itemAt: 0], nil)
            XCTAssertEqual(state[itemAt: 500], nil)
        }

        XCTAssertEqual(hasPreviousItem.pollValues(), [false])
        XCTAssertEqual(hasNextItem.pollValues(), [false])
    }

    func test_loadSong() {
        let sut = PlaybackQueue(dependencies: .mock())
        let song = Song.mock(id: UUID(uuidString: "3c121c55-9343-4f19-b90c-b616cdec7bdd")!)

        let source = TestSubscriber.subscribe(to: sut.source)
        let state = TestSubscriber.subscribe(to: sut.state)
        let hasPreviousItem = TestSubscriber.subscribe(to: sut.hasPreviousItem)
        let hasNextItem = TestSubscriber.subscribe(to: sut.hasNextItem)

        XCTAssertEqual(source.pollValues().count, 1)
        XCTAssertEqual(state.pollValues().count, 1)
        XCTAssertEqual(hasPreviousItem.pollValues().count, 1)
        XCTAssertEqual(hasNextItem.pollValues().count, 1)

        // load a song
        sut.load(with: song)

        XCTAssertEqual(source.pollValues(), [.song(song)])

        assertState(
            state,
            history: [],
            activeItemSong: song,
            userQueue: [],
            upNext: []
        ) { state in
            XCTAssertEqual(state[itemAt: -1], nil)
            XCTAssertEqual(state[itemAt: 0]?.song, song)
            XCTAssertEqual(state[itemAt: 1], nil)
        }

        XCTAssertEqual(hasPreviousItem.pollValues(), [false])
        XCTAssertEqual(hasNextItem.pollValues(), [false])
    }

    // MARK: - Helpers

    private func assertState<State: PlaybackQueueState>(
        _ testSubscriber: TestSubscriber<State, Never>,
        history: [Song],
        activeItemSong: Song?,
        userQueue: [Song],
        upNext: [Song],
        extraAssertions: (State) -> Void = { _ in },
        line: UInt = #line
    ) {
        let list = testSubscriber.pollValues()
        if list.count != 1 {
            XCTFail("Expected one state value, found \(list.count)", line: line)
        } else {
            assertState(
                list[safe: 0],
                history: history,
                activeItemSong: activeItemSong,
                userQueue: userQueue,
                upNext: upNext,
                extraAssertions: extraAssertions,
                line: line
            )
        }
    }

    private func assertState<State: PlaybackQueueState>(
        _ state: State?,
        history: [Song],
        activeItemSong: Song?,
        userQueue: [Song],
        upNext: [Song],
        extraAssertions: (State) -> Void = { _ in },
        line: UInt = #line
    ) {
        if let state {
            XCTAssertEqual(state.history.map(\.song), history, "history does not match", line: line)
            XCTAssertEqual(state.activeItem.map(\.song), activeItemSong, "activeItem does not match", line: line)
            XCTAssertEqual(state.userQueue.map(\.song), userQueue, "userQueue does not match", line: line)
            XCTAssertEqual(state.upNext.map(\.song), upNext, "upNext does not match", line: line)

            let expectedCount = history.count + (activeItemSong != nil ? 1 : 0) + userQueue.count + upNext.count
            XCTAssertEqual(state.count, expectedCount, "invalid count", line: line)
            XCTAssertEqual(state.activeItemIndex, state.count == 0 ? -1 : history.count, "invalid activeItemIndex", line: line)
            extraAssertions(state)
        } else {
            XCTFail("State is nil", line: line)
        }
    }
}

private extension PlaybackQueue.Dependencies {
    static func mock() -> Self {
        .init()
    }
}
