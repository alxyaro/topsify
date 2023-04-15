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
            activeItemSong: song,
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

    func test_goToItemAtIndex_doesNothingIfIndexIsActive() {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = [Song].mock(count: 5)
        sut.load(with: songs, source: nil)

        sut.goToNextItem()
        sut.goToNextItem()

        let state = TestSubscriber.subscribe(to: sut.state)

        XCTAssertEqual(try state.pollOnlyValue().activeItemIndex, 2)

        sut.goToItem(atIndex: 2)

        XCTAssertTrue(state.pollValues().isEmpty)
    }

    func test_goToItemAtIndex_whenGoingForward() {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = [Song].mock(count: 10)
        sut.load(with: songs, source: nil)

        let state = TestSubscriber.subscribe(to: sut.state)

        XCTAssertEqual(try state.pollOnlyValue().activeItemIndex, 0)

        sut.goToItem(atIndex: 2)

        assertState(
            state,
            history: songs[..<2],
            activeItemSong: songs[2],
            upNext: songs[3...]
        )

        sut.goToItem(atIndex: 3)

        assertState(
            state,
            history: songs[..<3],
            activeItemSong: songs[3],
            upNext: songs[4...]
        )

        sut.goToItem(atIndex: 100)

        assertState(
            state,
            history: songs[..<9],
            activeItemSong: songs[9],
            upNext: []
        )

        sut.goToItem(atIndex: 50)
        sut.goToItem(atIndex: 9)

        XCTAssertTrue(state.pollValues().isEmpty)
    }

    func test_goToItemAtIndex_whenGoingForward_userQueueItemsArePrioritizedAndDontGetAddedToHistory() {
        let songs = [Song].mock(count: 5)
        let queueSongs = [Song].mock(count: 3)

        let sut = PlaybackQueue(dependencies: .mock())
        sut.load(with: songs, source: nil)
        sut.goToItem(atIndex: 2)
        queueSongs.forEach(sut.addToQueue)

        let state = TestSubscriber.subscribe(to: sut.state)

        assertState(
            state,
            history: songs[..<2],
            activeItemSong: songs[2],
            userQueue: queueSongs,
            upNext: songs[3...]
        ) {
            XCTAssertEqual($0.activeItemIndex, 2)
            XCTAssertEqual($0.count, 8)
        }

        // index of first queue item (activeIndex + 1)
        sut.goToItem(atIndex: 2 + 1)

        assertState(
            state,
            history: songs[..<3],
            activeItemSong: queueSongs[0],
            userQueue: queueSongs[1...],
            upNext: songs[3...]
        ) {
            XCTAssertEqual($0.activeItemIndex, 3)
            XCTAssertEqual($0.count, 8)
        }

        // index of next last queue item (activeIndex + 2)
        sut.goToItem(atIndex: 3 + 2)

        assertState(
            state,
            history: songs[..<3],
            activeItemSong: queueSongs[2],
            userQueue: [],
            upNext: songs[3...]
        ) {
            // same index as before is expected, because userQueue items are not added to
            // history, so the activeItemIndex doesn't change & instead total count shrinks
            XCTAssertEqual($0.activeItemIndex, 3)
            XCTAssertEqual($0.count, 6)
        }

        // index of next upNext item (activeIndex + 1)
        sut.goToItem(atIndex: 3 + 1)

        assertState(
            state,
            history: songs[..<3],
            activeItemSong: songs[3],
            userQueue: [],
            upNext: songs[4...]
        ) {
            XCTAssertEqual($0.activeItemIndex, 3)
            XCTAssertEqual($0.count, 5)
        }
    }

    func test_goToItemAtIndex_whenGoingBackward() {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = [Song].mock(count: 10)
        sut.load(with: songs, source: nil)
        sut.goToItem(atIndex: 9)

        let state = TestSubscriber.subscribe(to: sut.state)

        XCTAssertEqual(try state.pollOnlyValue().activeItemIndex, 9)

        sut.goToItem(atIndex: 7)

        assertState(
            state,
            history: songs[..<7],
            activeItemSong: songs[7],
            upNext: songs[8...]
        )

        sut.goToItem(atIndex: 6)

        assertState(
            state,
            history: songs[..<6],
            activeItemSong: songs[6],
            upNext: songs[7...]
        )

        sut.goToItem(atIndex: -100)

        assertState(
            state,
            history: [],
            activeItemSong: songs[0],
            upNext: songs[1...]
        )

        sut.goToItem(atIndex: -1)
        sut.goToItem(atIndex: 0)

        XCTAssertTrue(state.pollValues().isEmpty)
    }

    func test_goToItemAtIndex_whenGoingBackward_activeUserQueueItemIsDiscarded() {
        let songs = [Song].mock(count: 5)
        let queueSong = Song.mock()

        let sut = PlaybackQueue(dependencies: .mock())
        sut.load(with: songs, source: nil)
        sut.goToItem(atIndex: 2)
        sut.addToQueue(queueSong)
        sut.goToNextItem()

        let state = TestSubscriber.subscribe(to: sut.state)

        assertState(
            state,
            history: songs[..<3],
            activeItemSong: queueSong,
            userQueue: [],
            upNext: songs[3...]
        ) {
            XCTAssertEqual($0.activeItemIndex, 3)
            XCTAssertEqual($0.count, 6)
        }

        // going back by 2
        sut.goToItem(atIndex: 3 - 2)

        assertState(
            state,
            history: songs[..<1],
            activeItemSong: songs[1],
            userQueue: [],
            upNext: songs[2...]
        ) {
            XCTAssertEqual($0.activeItemIndex, 1)
            XCTAssertEqual($0.count, 5)
        }
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

    func test_goToNextItem_withItemInQueue() {
        let sut = PlaybackQueue(dependencies: .mock())

        let song = Song.mock()
        sut.addToQueue(song)

        let state = TestSubscriber.subscribe(to: sut.state)

        assertState(state, activeItemSong: nil, userQueue: [song])

        sut.goToNextItem()

        assertState(state, activeItemSong: song, userQueue: [])
    }

    func test_goToNextItem_discardsUserQueueItems() {
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

    func test_goToPreviousItem_discardsUserQueueItems() {
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
            XCTAssertEqual(state.activeItemIndex, state.activeItem != nil ? history.count : -1, "invalid activeItemIndex", line: line)
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
