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
            XCTAssertEqual(state[itemAt: .history(0)], nil)
            XCTAssertEqual(state[itemAt: .activeItem], nil)
            XCTAssertEqual(state[itemAt: .userQueue(0)], nil)
            XCTAssertEqual(state[itemAt: .upNext(0)], nil)
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
            activeItemSong: song,
            upNext: []
        ) { state in
            XCTAssertEqual(state[itemAt: .history(0)], nil)
            XCTAssertEqual(state[itemAt: .activeItem]?.song, song)
            XCTAssertEqual(state[itemAt: .userQueue(0)], nil)
            XCTAssertEqual(state[itemAt: .upNext(0)], nil)
        }

        XCTAssertEqual(hasPreviousItem.pollValues(), [false])
        XCTAssertEqual(hasNextItem.pollValues(), [false])
    }

    func test_loadWithMultipleSongs() {
        let songs = [Song].mock(count: 3)
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
            activeItemSong: songs[0],
            upNext: songs[1...]
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

    func test_goToNextItem() {
        let songs = [Song].mock(count: 3)
        let sut = PlaybackQueue(dependencies: .mock(
            contentService: MockContentService(
                fetchSongs: { _ in .just(songs) }
            )
        ))

        sut.load(with: .playlist(.mock()))

        let state = TestSubscriber.subscribe(to: sut.state)
        let hasPreviousItem = TestSubscriber.subscribe(to: sut.hasPreviousItem)
        let hasNextItem = TestSubscriber.subscribe(to: sut.hasNextItem)

        assertState(
            state,
            history: [],
            activeItemSong: songs[0],
            upNext: songs[1...]
        )
        XCTAssertEqual(hasPreviousItem.pollValues(), [false])
        XCTAssertEqual(hasNextItem.pollValues(), [true])

        sut.goToNextItem()

        assertState(
            state,
            history: songs[..<1],
            activeItemSong: songs[1],
            upNext: songs[2...]
        )
        XCTAssertEqual(hasPreviousItem.pollValues(), [true])
        XCTAssertEqual(hasNextItem.pollValues(), [true])

        sut.goToNextItem()

        assertState(
            state,
            history: songs[..<2],
            activeItemSong: songs[2],
            upNext: []
        )
        XCTAssertEqual(hasPreviousItem.pollValues(), [true])
        XCTAssertEqual(hasNextItem.pollValues(), [false])

        sut.goToNextItem()

        XCTAssertEqual(state.pollValues().isEmpty, true)
        XCTAssertEqual(hasPreviousItem.pollValues(), [])
        XCTAssertEqual(hasNextItem.pollValues(), [])
    }

    func test_goToPreviousItem() {
        let songs = [Song].mock(count: 3)
        let sut = PlaybackQueue(dependencies: .mock(
            contentService: MockContentService(
                fetchSongs: { _ in .just(songs) }
            )
        ))

        sut.load(with: .playlist(.mock()))
        sut.goToNextItem()
        sut.goToNextItem()
        sut.goToNextItem()

        let state = TestSubscriber.subscribe(to: sut.state)
        let hasPreviousItem = TestSubscriber.subscribe(to: sut.hasPreviousItem)
        let hasNextItem = TestSubscriber.subscribe(to: sut.hasNextItem)

        assertState(
            state,
            history: songs[..<2],
            activeItemSong: songs[2],
            upNext: []
        )
        XCTAssertEqual(hasPreviousItem.pollValues(), [true])
        XCTAssertEqual(hasNextItem.pollValues(), [false])

        sut.goToPreviousItem()

        assertState(
            state,
            history: songs[..<1],
            activeItemSong: songs[1],
            upNext: songs[2...]
        )
        XCTAssertEqual(hasPreviousItem.pollValues(), [true])
        XCTAssertEqual(hasNextItem.pollValues(), [true])

        sut.goToPreviousItem()

        assertState(
            state,
            history: [],
            activeItemSong: songs[0],
            upNext: songs[1...]
        )
        XCTAssertEqual(hasPreviousItem.pollValues(), [false])
        XCTAssertEqual(hasNextItem.pollValues(), [true])

        sut.goToPreviousItem()

        XCTAssertEqual(state.pollValues().isEmpty, true)
        XCTAssertEqual(hasPreviousItem.pollValues(), [])
        XCTAssertEqual(hasNextItem.pollValues(), [])
    }

    func test_goToItemAtIndex_forActiveItemIndex() {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = [Song].mock(count: 5)
        sut.load(with: songs, source: nil)

        let state = TestSubscriber.subscribe(to: sut.state)

        XCTAssertEqual(try state.pollOnlyValue().activeItemIndex, 0)

        sut.goToItem(atIndex: .activeItem)

        XCTAssertTrue(state.pollValues().isEmpty)
    }

    func test_goToItemAtIndex_forHistoryIndex() {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = [Song].mock(count: 5)
        sut.load(with: songs, source: nil)
        sut.goToNextItem()
        sut.goToNextItem()

        let state = TestSubscriber.subscribe(to: sut.state)

        assertState(
            state,
            history: songs[..<2],
            activeItemSong: songs[2],
            upNext: songs[3...]
        )

        sut.goToItem(atIndex: .history(0))

        assertState(
            state,
            history: [],
            activeItemSong: songs[0],
            upNext: songs[1...]
        )
    }

    func test_goToItemAtIndex_forUserQueueIndex() {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = [Song].mock(count: 5)
        let queueSongs = [Song].mock(count: 3)
        sut.load(with: songs, source: nil)
        queueSongs.forEach(sut.addToQueue(_:))

        let state = TestSubscriber.subscribe(to: sut.state)

        assertState(
            state,
            activeItemSong: songs[0],
            userQueue: queueSongs,
            upNext: songs[1...]
        )

        sut.goToItem(atIndex: .userQueue(1))

        assertState(
            state,
            history: songs[0..<1],
            activeItemSong: queueSongs[1],
            userQueue: queueSongs[2...],
            upNext: songs[1...]
        )
    }

    func test_goToItemAtIndex_forUpNextIndex() {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = [Song].mock(count: 5)
        sut.load(with: songs, source: nil)

        let state = TestSubscriber.subscribe(to: sut.state)

        assertState(
            state,
            activeItemSong: songs[0],
            upNext: songs[1...]
        )

        sut.goToItem(atIndex: .upNext(2))

        assertState(
            state,
            history: songs[..<3],
            activeItemSong: songs[3],
            upNext: songs[4...]
        )
    }

    func test_addToQueue() {
        let sut = PlaybackQueue(dependencies: .mock())

        let state = TestSubscriber.subscribe(to: sut.state)

        assertState(
            state,
            history: [],
            activeItemSong: nil,
            userQueue: [],
            upNext: []
        )

        let song1 = Song.mock()
        let song2 = Song.mock()

        sut.addToQueue(song1)

        assertState(state, userQueue: [song1])

        sut.addToQueue(song2)

        assertState(state, userQueue: [song1, song2])

        sut.addToQueue(song1)

        assertState(state, userQueue: [song1, song2, song1])
    }

    func test_goToNextItem_takesUserQueueItemIfAvailable() {
        let sut = PlaybackQueue(dependencies: .mock())

        let song = Song.mock()
        let song2 = Song.mock()
        sut.load(with: [song], source: nil)
        sut.addToQueue(song2)

        let state = TestSubscriber.subscribe(to: sut.state)

        assertState(state, history: [], activeItemSong: song, userQueue: [song2])

        sut.goToNextItem()

        assertState(state, history: [song], activeItemSong: song2, userQueue: [])
    }

    func test_goToNextItem_takesUserQueueItemIfAvailable_whenNoActiveItem() {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = [Song].mock(count: 2)
        songs.forEach(sut.addToQueue(_:))

        let state = TestSubscriber.subscribe(to: sut.state)

        assertState(state, activeItemSong: nil, userQueue: songs)

        sut.goToNextItem()

        assertState(state, activeItemSong: songs[0], userQueue: songs[1...])
    }

    func test_goToNextItem_doesNotAddUserQueueItemsToHistory() {
        let sut = PlaybackQueue(dependencies: .mock())

        let song = Song.mock()
        sut.addToQueue(song)
        sut.addToQueue(song)

        let state = TestSubscriber.subscribe(to: sut.state)

        assertState(state, userQueue: [song, song])

        sut.goToNextItem()

        assertState(state, activeItemSong: song, userQueue: [song])

        sut.goToNextItem()

        assertState(state, history: [], activeItemSong: song, userQueue: [])
    }

    func test_goToPreviousItem_doesNotAddUserQueueItemsToHistory() {
        let sut = PlaybackQueue(dependencies: .mock())

        let song = Song.mock()
        let queueSong = Song.mock()
        sut.load(with: [song], source: nil)
        sut.addToQueue(queueSong)
        sut.goToNextItem()

        let state = TestSubscriber.subscribe(to: sut.state)

        assertState(state, history: [song], activeItemSong: queueSong)

        sut.goToPreviousItem()

        assertState(state, history: [], activeItemSong: song, userQueue: [])
    }

    // MARK: - Helpers

    private func assertState<State: PlaybackQueueState>(
        _ testSubscriber: TestSubscriber<State, Never>,
        history: some Collection<Song> = [],
        activeItemSong: Song? = nil,
        userQueue: some Collection<Song> = [],
        upNext: some Collection<Song> = [],
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
        history: some Collection<Song>,
        activeItemSong: Song?,
        userQueue: some Collection<Song>,
        upNext: some Collection<Song>,
        extraAssertions: (State) -> Void = { _ in },
        line: UInt = #line
    ) {
        if let state {
            XCTAssertEqual(state.history.map(\.song), Array(history), "history does not match", line: line)
            XCTAssertEqual(state.activeItem.map(\.song), activeItemSong, "activeItem does not match", line: line)
            XCTAssertEqual(state.userQueue.map(\.song), Array(userQueue), "userQueue does not match", line: line)
            XCTAssertEqual(state.upNext.map(\.song), Array(upNext), "upNext does not match", line: line)

            let expectedCount = history.count + (activeItemSong != nil ? 1 : 0) + userQueue.count + upNext.count
            XCTAssertEqual(state.count, expectedCount, "invalid count", line: line)
            XCTAssertEqual(state.activeItemIndex, state.activeItem != nil ? history.count : nil, "invalid activeItemIndex", line: line)
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
