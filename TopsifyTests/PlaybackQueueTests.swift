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

    func test_loadWithSingleSong() {
        let song = Song.mock()
        let sut = PlaybackQueue(dependencies: .mock(
            contentService: .init(
                fetchSongs: { _ in .just([song]) }
            )
        ))

        let source = TestSubscriber.subscribe(to: sut.source)
        let state = TestSubscriber.subscribe(to: sut.state)
        let hasPreviousItem = TestSubscriber.subscribe(to: sut.hasPreviousItem)
        let hasNextItem = TestSubscriber.subscribe(to: sut.hasNextItem)

        XCTAssertEqual(source.pollValues().count, 1)
        XCTAssertEqual(state.pollValues().count, 1)
        XCTAssertEqual(hasPreviousItem.pollValues().count, 1)
        XCTAssertEqual(hasNextItem.pollValues().count, 1)

        let album = Album.mock()

        // perform load
        sut.load(with: .album(album))
        // duplicates should be ignored
        sut.load(with: .album(album))

        XCTAssertEqual(source.pollValues(), [.album(album)])

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

    func test_loadWithMultipleSongs() {
        let songs = [
            Song.mock(),
            Song.mock(),
            Song.mock()
        ]
        let songsPublisher = TestPublisher<[Song], Error>()

        let sut = PlaybackQueue(dependencies: .mock(
            contentService: MockContentService(
                fetchSongs: { _ in songsPublisher.eraseToAnyPublisher() }
            )
        ))

        let source = TestSubscriber.subscribe(to: sut.source)
        let state = TestSubscriber.subscribe(to: sut.state)
        let hasPreviousItem = TestSubscriber.subscribe(to: sut.hasPreviousItem)
        let hasNextItem = TestSubscriber.subscribe(to: sut.hasNextItem)

        XCTAssertEqual(source.pollValues(), [nil])
        XCTAssertEqual(state.pollValues().count, 1)
        XCTAssertEqual(hasPreviousItem.pollValues().count, 1)
        XCTAssertEqual(hasNextItem.pollValues().count, 1)

        let album = Album.mock()

        // perform load
        sut.load(with: .album(album))
        // duplicates should be ignored
        sut.load(with: .album(album))

        XCTAssertEqual(source.pollValues(), [.album(album)])
        XCTAssertEqual(state.pollValues().isEmpty, true)
        XCTAssertEqual(hasPreviousItem.pollValues(), [])
        XCTAssertEqual(hasNextItem.pollValues(), [])

        songsPublisher.send(songs)

        XCTAssertEqual(source.pollValues(), [])
        assertState(
            state,
            history: [],
            activeItemSong: songs[0],
            userQueue: [],
            upNext: Array(songs[1...])
        )
        XCTAssertEqual(hasPreviousItem.pollValues(), [false])
        XCTAssertEqual(hasNextItem.pollValues(), [true])
    }

    func test_load_clearsSource_whenErrorOccurs() {
        let songsPublisher = TestPublisher<[Song], Error>()
        let sut = PlaybackQueue(dependencies: .mock(
            contentService: MockContentService(
                fetchSongs: { _ in songsPublisher.eraseToAnyPublisher() }
            )
        ))

        let source = TestSubscriber.subscribe(to: sut.source)

        XCTAssertEqual(source.pollValues(), [nil])

        let playlist = Playlist.mock()
        sut.load(with: .playlist(playlist))

        XCTAssertEqual(source.pollValues(), [.playlist(playlist)])

        songsPublisher.send(failure: GenericError(message: "d'oh!"))

        XCTAssertEqual(source.pollValues(), [nil])
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
    static func mock(
        contentService: MockContentService = .init()
    ) -> Self {
        .init(
            contentService: contentService
        )
    }
}
