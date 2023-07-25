// Created by Alex Yaro on 2023-04-07.

@testable import Topsify
import Combine
import XCTest
import TestHelpers

final class PlaybackQueueTests: XCTestCase {

    func test_initialState() {
        let sut = PlaybackQueue(dependencies: .mock())

        let source = TestSubscriber.subscribe(to: sut.source)
        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
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

    // MARK: - load(with:)

    func test_loadWithSingleSong() {
        let song = Song.mock()
        let sut = PlaybackQueue(dependencies: .mock(
            contentService: .init(
                fetchSongs: { _ in .just([song]) }
            )
        ))

        let source = TestSubscriber.subscribe(to: sut.source)
        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
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
        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
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

        songsPublisher.send(completion: .failure(GenericError(message: "d'oh!")))

        XCTAssertEqual(source.pollValues(), [nil])
    }

    // MARK: - addToQueue

    func test_addToQueue() {
        let sut = PlaybackQueue(dependencies: .mock())

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)

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

    // MARK: - goToNextItem() and goToPreviousItem()

    func test_goToNextItem() {
        let songs = [Song].mock(count: 3)
        let sut = PlaybackQueue(dependencies: .mock(
            contentService: MockContentService(
                fetchSongs: { _ in .just(songs) }
            )
        ))

        sut.load(with: .playlist(.mock()))

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
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
            upNext: songs[2...],
            context: .movedToNextItem(removedItem: nil)
        )
        XCTAssertEqual(hasPreviousItem.pollValues(), [true])
        XCTAssertEqual(hasNextItem.pollValues(), [true])

        sut.goToNextItem()

        assertState(
            state,
            history: songs[..<2],
            activeItemSong: songs[2],
            upNext: [],
            context: .movedToNextItem(removedItem: nil)
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

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
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
            upNext: songs[2...],
            context: .movedToPreviousItem(removedItem: nil)
        )
        XCTAssertEqual(hasPreviousItem.pollValues(), [true])
        XCTAssertEqual(hasNextItem.pollValues(), [true])

        sut.goToPreviousItem()

        assertState(
            state,
            history: [],
            activeItemSong: songs[0],
            upNext: songs[1...],
            context: .movedToPreviousItem(removedItem: nil)
        )
        XCTAssertEqual(hasPreviousItem.pollValues(), [false])
        XCTAssertEqual(hasNextItem.pollValues(), [true])

        sut.goToPreviousItem()

        XCTAssertEqual(state.pollValues().isEmpty, true)
        XCTAssertEqual(hasPreviousItem.pollValues(), [])
        XCTAssertEqual(hasNextItem.pollValues(), [])
    }

    func test_goToNextItem_takesUserQueueItemIfAvailable() {
        let sut = PlaybackQueue(dependencies: .mock())

        let song = Song.mock()
        let song2 = Song.mock()
        sut.load(with: [song], source: nil)
        sut.addToQueue(song2)

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)

        assertState(state, history: [], activeItemSong: song, userQueue: [song2])

        sut.goToNextItem()

        assertState(state, history: [song], activeItemSong: song2, userQueue: [], context: .movedToNextItem(removedItem: nil))
    }

    func test_goToNextItem_takesUserQueueItemIfAvailable_whenNoActiveItem() {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = [Song].mock(count: 2)
        songs.forEach(sut.addToQueue(_:))

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)

        assertState(state, activeItemSong: nil, userQueue: songs)

        sut.goToNextItem()

        assertState(state, activeItemSong: songs[0], userQueue: songs[1...], context: .movedToNextItem(removedItem: nil))
    }

    func test_goToNextItem_doesNotAddUserQueueItemsToHistory() {
        let sut = PlaybackQueue(dependencies: .mock())

        let song = Song.mock()
        sut.addToQueue(song)
        sut.addToQueue(song)

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)

        assertState(state, userQueue: [song, song])

        sut.goToNextItem()

        var activeItem: PlaybackQueueItem?
        assertState(state, activeItemSong: song, userQueue: [song], context: .movedToNextItem(removedItem: nil)) {
            activeItem = $0.activeItem
        }

        sut.goToNextItem()

        assertState(state, history: [], activeItemSong: song, userQueue: [], context: .movedToNextItem(removedItem: activeItem))
    }

    func test_goToPreviousItem_doesNotAddUserQueueItemsToHistory() {
        let sut = PlaybackQueue(dependencies: .mock())

        let song = Song.mock()
        let queueSong = Song.mock()
        sut.load(with: [song], source: nil)
        sut.addToQueue(queueSong)
        sut.goToNextItem()

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)

        var activeItem: PlaybackQueueItem?
        assertState(state, history: [song], activeItemSong: queueSong) {
            activeItem = $0.activeItem
        }

        sut.goToPreviousItem()

        assertState(state, history: [], activeItemSong: song, userQueue: [], context: .movedToPreviousItem(removedItem: activeItem))
    }

    // MARK: - goToItem(atIndex:)

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

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)

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

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)

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
        let queueSong = Song.mock()
        sut.load(with: songs, source: nil)
        sut.addToQueue(queueSong)

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)

        assertState(
            state,
            activeItemSong: songs[0],
            userQueue: [queueSong],
            upNext: songs[1...]
        )

        sut.goToItem(atIndex: .upNext(2))

        assertState(
            state,
            history: songs[..<3],
            activeItemSong: songs[3],
            userQueue: [],
            upNext: songs[4...]
        )
    }

    func test_goToItemAtIndex_forUpNextIndex_withoutEmptyUserQueueIfUpNextIndex() {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = [Song].mock(count: 5)
        let queueSong = Song.mock()
        sut.load(with: songs, source: nil)
        sut.addToQueue(queueSong)

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)

        assertState(
            state,
            activeItemSong: songs[0],
            userQueue: [queueSong],
            upNext: songs[1...]
        )

        sut.goToItem(atIndex: .upNext(2), emptyUserQueueIfUpNextIndex: false)

        assertState(
            state,
            history: songs[..<3],
            activeItemSong: songs[3],
            userQueue: [queueSong],
            upNext: songs[4...]
        )
    }

    // MARK: - moveItem(to:from:)

    func test_moveItem_fromAnInvalidIndex_isNoOp() {
        let (_, _, _, _, sut) = makeSamplePlaybackQueue()
        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        XCTAssertFalse(sut.moveItem(from: .history(1), to: .userQueue(0)))
        XCTAssertFalse(sut.moveItem(from: .history(1), to: .upNext(0)))
        XCTAssertFalse(sut.moveItem(from: .userQueue(1), to: .history(0)))
        XCTAssertFalse(sut.moveItem(from: .userQueue(1), to: .upNext(0)))
        XCTAssertFalse(sut.moveItem(from: .upNext(1), to: .history(0)))
        XCTAssertFalse(sut.moveItem(from: .upNext(1), to: .userQueue(0)))

        XCTAssertFalse(sut.moveItem(from: .history(-1), to: .userQueue(0)))
        XCTAssertFalse(sut.moveItem(from: .userQueue(-1), to: .history(0)))

        XCTAssertTrue(state.pollEvents().isEmpty)
    }

    func test_moveItem_toAnInvalidIndex_isNoOp() {
        let (_, _, _, _, sut) = makeSamplePlaybackQueue()
        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        XCTAssertFalse(sut.moveItem(from: .history(0), to: .userQueue(2)))
        XCTAssertFalse(sut.moveItem(from: .history(0), to: .upNext(2)))
        XCTAssertFalse(sut.moveItem(from: .userQueue(0), to: .history(2)))
        XCTAssertFalse(sut.moveItem(from: .userQueue(0), to: .upNext(2)))
        XCTAssertFalse(sut.moveItem(from: .upNext(0), to: .history(2)))
        XCTAssertFalse(sut.moveItem(from: .upNext(0), to: .userQueue(2)))

        XCTAssertFalse(sut.moveItem(from: .history(0), to: .userQueue(-1)))
        XCTAssertFalse(sut.moveItem(from: .userQueue(0), to: .history(-1)))

        XCTAssertTrue(state.pollEvents().isEmpty)
    }

    func test_moveItem_from_activeItem_isNoOp() {
        let (_, _, _, _, sut) = makeSamplePlaybackQueue()
        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        XCTAssertFalse(sut.moveItem(from: .activeItem, to: .history(0)))
        XCTAssertFalse(sut.moveItem(from: .activeItem, to: .userQueue(0)))
        XCTAssertFalse(sut.moveItem(from: .activeItem, to: .upNext(0)))

        XCTAssertTrue(state.pollValues().isEmpty)
    }

    func test_moveItem_to_activeItem_isNoOp() {
        let (_, _, _, _, sut) = makeSamplePlaybackQueue()
        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        XCTAssertFalse(sut.moveItem(from: .history(0), to: .activeItem))
        XCTAssertFalse(sut.moveItem(from: .userQueue(0), to: .activeItem))
        XCTAssertFalse(sut.moveItem(from: .upNext(0), to: .activeItem))

        XCTAssertTrue(state.pollValues().isEmpty)
    }

    func test_moveItem_from_history_to_userQueue() {
        let (historyItem, activeItem, userQueueItem, upNextItem, sut) = makeSamplePlaybackQueue()
        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        XCTAssertTrue(sut.moveItem(from: .history(0), to: .userQueue(0)))

        assertState(
            state,
            history: [],
            activeItemSong: activeItem,
            userQueue: [historyItem, userQueueItem],
            upNext: [upNextItem]
        )
    }

    func test_moveItem_from_history_to_upNext() {
        let (historyItem, activeItem, userQueueItem, upNextItem, sut) = makeSamplePlaybackQueue()
        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        XCTAssertTrue(sut.moveItem(from: .history(0), to: .upNext(1)))

        assertState(
            state,
            history: [],
            activeItemSong: activeItem,
            userQueue: [userQueueItem],
            upNext: [upNextItem, historyItem]
        )
    }

    func test_moveItem_from_userQueue_to_history() {
        let (historyItem, activeItem, userQueueItem, upNextItem, sut) = makeSamplePlaybackQueue()
        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        XCTAssertTrue(sut.moveItem(from: .userQueue(0), to: .history(1)))

        assertState(
            state,
            history: [historyItem, userQueueItem],
            activeItemSong: activeItem,
            userQueue: [],
            upNext: [upNextItem]
        )
    }

    func test_moveItem_from_userQueue_to_upNext() {
        let (historyItem, activeItem, userQueueItem, upNextItem, sut) = makeSamplePlaybackQueue()
        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        XCTAssertTrue(sut.moveItem(from: .userQueue(0), to: .upNext(0)))

        assertState(
            state,
            history: [historyItem],
            activeItemSong: activeItem,
            userQueue: [],
            upNext: [userQueueItem, upNextItem]
        )
    }

    func test_moveItem_from_upNext_to_history() {
        let (historyItem, activeItem, userQueueItem, upNextItem, sut) = makeSamplePlaybackQueue()
        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        XCTAssertTrue(sut.moveItem(from: .upNext(0), to: .history(0)))

        assertState(
            state,
            history: [upNextItem, historyItem],
            activeItemSong: activeItem,
            userQueue: [userQueueItem],
            upNext: []
        )
    }

    func test_moveItem_from_upNext_to_userQueue() {
        let (historyItem, activeItem, userQueueItem, upNextItem, sut) = makeSamplePlaybackQueue()
        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        XCTAssertTrue(sut.moveItem(from: .upNext(0), to: .userQueue(1)))

        assertState(
            state,
            history: [historyItem],
            activeItemSong: activeItem,
            userQueue: [userQueueItem, upNextItem],
            upNext: []
        )
    }

    // MARK: - moveItemsToQueue(at:)

    func test_moveItemsToQueue_withEmptyInput() {
        let sut = PlaybackQueue(dependencies: .mock())

        sut.load(with: .mock(count: 5), source: nil)

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        sut.moveItemsToQueue(at: [])

        XCTAssertTrue(state.pollValues().isEmpty)
    }

    func test_moveItemsToQueue_withInvalidIndices() {
        let sut = PlaybackQueue(dependencies: .mock())

        sut.load(with: .mock(count: 5), source: nil)

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        sut.moveItemsToQueue(at: [
            .activeItem,
            .userQueue(-10),
            .history(0),
            .upNext(100)
        ])

        XCTAssertTrue(state.pollValues().isEmpty)
    }

    func test_moveItemsToQueue_withValidAndInvalidIndices() {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = makeSongs(count: 11)
        let userQueueSongs = makeSongs(count: 5)
        sut.load(with: songs, source: nil)
        sut.goToItem(atIndex: .upNext(4))
        userQueueSongs.forEach(sut.addToQueue)

        let historySongs = Array(songs[0..<5])
        let upNextSongs = Array(songs[6...])

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        sut.moveItemsToQueue(at: [
            .activeItem,

            .userQueue(-1),
            .userQueue(1),
            .userQueue(50),

            .upNext(-1),
            .upNext(1),

            .history(-1),
            .history(2),
            .history(0),
            .history(1000),

            .upNext(4),
            .upNext(50)
        ])

        var expectedHistory = historySongs
        expectedHistory.remove(at: 2)
        expectedHistory.remove(at: 0)

        var expectedUserQueue = userQueueSongs
        expectedUserQueue.remove(at: 1)
        expectedUserQueue.append(historySongs[0])
        expectedUserQueue.append(historySongs[2])
        expectedUserQueue.append(userQueueSongs[1])
        expectedUserQueue.append(upNextSongs[1])
        expectedUserQueue.append(upNextSongs[4])

        var expectedUpNext = upNextSongs
        expectedUpNext.remove(at: 4)
        expectedUpNext.remove(at: 1)

        assertState(
            state,
            history: expectedHistory,
            activeItemSong: songs[5],
            userQueue: expectedUserQueue,
            upNext: expectedUpNext
        )
    }

    // MARK: - removeItems(at:)

    func test_removeItems_withEmptyInput() {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = makeSongs(count: 5)
        let queueSongs = makeSongs(count: 3)
        sut.load(with: songs, source: nil)
        queueSongs.forEach(sut.addToQueue(_:))

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        sut.removeItems(at: [])

        XCTAssertTrue(state.pollValues().isEmpty)
    }

    func test_removeItems_fromInvalidIndices_isNoOp() {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = makeSongs(count: 1)
        sut.load(with: songs, source: nil)

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        sut.removeItems(at: [
            .history(-1),
            .history(100),
            .activeItem,
            .userQueue(500),
            .upNext(-100)
        ])

        XCTAssertTrue(state.pollValues().isEmpty)
    }

    func test_removeItems_fromValidAndInvalidIndices() {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = makeSongs(count: 11)
        let queueSongs = makeSongs(count: 5)
        sut.load(with: songs, source: nil)
        sut.goToItem(atIndex: .upNext(4))
        queueSongs.forEach(sut.addToQueue)

        let state = TestSubscriber.subscribe(to: sut.stateWithContext)
        state.discardStoredEvents()

        sut.removeItems(at: [
            .history(-1),
            .history(0),
            .history(2),
            .history(1000),

            .activeItem,

            .userQueue(-1),
            .userQueue(1),
            .userQueue(50),

            .upNext(-1),
            .upNext(1),
            .upNext(4),
            .upNext(50)
        ])

        var expectedHistory = Array(songs[0..<5])
        expectedHistory.remove(at: 2)
        expectedHistory.remove(at: 0)

        var expectedUserQueue = queueSongs
        expectedUserQueue.remove(at: 1)

        var expectedUpNext = Array(songs[6...])
        expectedUpNext.remove(at: 4)
        expectedUpNext.remove(at: 1)

        assertState(
            state,
            history: expectedHistory,
            activeItemSong: songs[5],
            userQueue: expectedUserQueue,
            upNext: expectedUpNext
        )
    }

    // MARK: - Helper Tests

    func test_makeSamplePlaybackQueue() {
        let (historyItem, activeItem, userQueueItem, upNextItem, sut) = makeSamplePlaybackQueue()
        let state = TestSubscriber.subscribe(to: sut.stateWithContext)

        assertState(
            state,
            history: [historyItem],
            activeItemSong: activeItem,
            userQueue: [userQueueItem],
            upNext: [upNextItem]
        )
    }

    // MARK: - Helpers

    private func makeSamplePlaybackQueue() -> (historyItem: Song, activeItem: Song, userQueueItem: Song, upNextItem: Song, playbackQueue: PlaybackQueue) {
        let sut = PlaybackQueue(dependencies: .mock())

        let songs = [Song].mock(count: 3)
        let queueSong = Song.mock()

        sut.load(with: songs, source: nil)
        sut.goToNextItem()
        sut.addToQueue(queueSong)

        return (historyItem: songs[0], activeItem: songs[1], userQueueItem: queueSong, upNextItem: songs[2], playbackQueue: sut)
    }

    private func makeSongs(count: Int) -> [Song] {
        .mock(count: count)
    }

    private func assertState<State: PlaybackQueueState>(
        _ testSubscriber: TestSubscriber<(state: State, context: PlaybackQueueStateContext?), Never>,
        history: some Collection<Song> = [],
        activeItemSong: Song? = nil,
        userQueue: some Collection<Song> = [],
        upNext: some Collection<Song> = [],
        context: PlaybackQueueStateContext? = nil,
        extraAssertions: (State) -> Void = { _ in },
        line: UInt = #line
    ) {
        let list = testSubscriber.pollValues()
        if list.count != 1 {
            XCTFail("Expected one state value, found \(list.count)", line: line)
        } else {
            let stateWithContext = list[0]
            assertState(
                stateWithContext,
                history: history,
                activeItemSong: activeItemSong,
                userQueue: userQueue,
                upNext: upNext,
                context: context,
                line: line
            )
            extraAssertions(stateWithContext.state)
        }
    }

    private func assertState<State: PlaybackQueueState>(
        _ stateWithContext: (state: State, context: PlaybackQueueStateContext?),
        history: some Collection<Song>,
        activeItemSong: Song?,
        userQueue: some Collection<Song>,
        upNext: some Collection<Song>,
        context expectedContext: PlaybackQueueStateContext? = nil,
        line: UInt = #line
    ) {
        let (state, context) = stateWithContext

        XCTAssertEqual(state.history.map(\.song), Array(history), "history does not match", line: line)
        XCTAssertEqual(state.activeItem.map(\.song), activeItemSong, "activeItem does not match", line: line)
        XCTAssertEqual(state.userQueue.map(\.song), Array(userQueue), "userQueue does not match", line: line)
        XCTAssertEqual(state.upNext.map(\.song), Array(upNext), "upNext does not match", line: line)

        XCTAssertTrue(state.history.allSatisfy { !$0.isUserQueueItem }, "history contained item(s) with isUserQueueItem = true", line: line)
        XCTAssertTrue(state.userQueue.allSatisfy { $0.isUserQueueItem }, "userQueue contained item(s) with isUserQueueItem = false", line: line)
        XCTAssertTrue(state.upNext.allSatisfy { !$0.isUserQueueItem }, "upNext contained item(s) with isUserQueueItem = true", line: line)

        let expectedCount = history.count + (activeItemSong != nil ? 1 : 0) + userQueue.count + upNext.count
        XCTAssertEqual(state.count, expectedCount, "invalid count", line: line)
        XCTAssertEqual(state.activeItemIndex, state.activeItem != nil ? history.count : nil, "invalid activeItemIndex", line: line)

        XCTAssertEqual(context, expectedContext, line: line)
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
