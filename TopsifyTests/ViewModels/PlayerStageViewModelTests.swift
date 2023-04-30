// Created by Alex Yaro on 2023-04-21.

@testable import Topsify
import Combine
import TestHelpers
import XCTest

final class PlayerStageViewModelTests: XCTestCase {

    func test_stoppedOnItemAtIndexInput_notifiesPlaybackQueue() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.stateValue.activeItem = .init(song: .mock())
        playbackQueue.stateValue.upNext = [.init(song: .mock())]

        let sut = PlayerStageViewModel(playbackQueue: playbackQueue)

        let stoppedOnItemAtIndex = TestPublisher<(index: Int, itemList: PlayerStageViewModel.ItemList), Never>()

        let outputs = sut.bind(inputs: .init(
            stoppedOnItemAtIndex: stoppedOnItemAtIndex.eraseToAnyPublisher(),
            willBeginDragging: .never()
        ))

        let goToItemAtIndex = TestSubscriber.subscribe(to: playbackQueue.goToItemAtIndexSubject)
        let itemList = TestSubscriber.subscribe(to: outputs.itemList)

        XCTAssertTrue(goToItemAtIndex.pollValues().isEmpty)

        stoppedOnItemAtIndex.send((
            index: 1,
            itemList: try XCTUnwrap(try itemList.pollOnlyValue())
        ))

        XCTAssertEqual(try goToItemAtIndex.pollOnlyValue().index, .upNext(0))
    }

    func test_itemListOutput_derivedFromPlaybackQueueState() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.stateValue.history = [.init(song: .mock())]
        playbackQueue.stateValue.activeItem = .init(song: .mock())
        playbackQueue.stateValue.upNext = [.init(song: .mock())]

        let sut = PlayerStageViewModel(playbackQueue: playbackQueue)

        let outputs = sut.bind(inputs: .init(
            stoppedOnItemAtIndex: .never(),
            willBeginDragging: .never()
        ))

        let itemListOutput = TestSubscriber.subscribe(to: outputs.itemList)

        let itemList = try XCTUnwrap(try itemListOutput.pollOnlyValue())
        XCTAssertEqual(itemList.count, 3)
        XCTAssertEqual(itemList.activeItemIndex, 1)
        XCTAssertEqual(itemList[itemAt: 0], .from(playbackQueue.stateValue.history[0]))
        XCTAssertEqual(itemList[itemAt: 1], .from(playbackQueue.stateValue.activeItem!))
        XCTAssertEqual(itemList[itemAt: 2], .from(playbackQueue.stateValue.upNext[0]))
        XCTAssertEqual(itemList.transition, nil)
    }

    func test_itemListOutput_withMovedToNextItemContext() throws {
        let playbackQueue = MockPlaybackQueue()

        let removedItem = PlaybackQueueItem(song: .mock())

        playbackQueue.stateValue = .init(
            history: [.init(song: .mock())],
            activeItem: .init(song: .mock()),
            upNext: [.init(song: .mock())],
            context: .movedToNextItem(removedItem: removedItem)
        )

        let sut = PlayerStageViewModel(playbackQueue: playbackQueue)

        let outputs = sut.bind(inputs: .init(
            stoppedOnItemAtIndex: .never(),
            willBeginDragging: .never()
        ))

        let itemListOutput = TestSubscriber.subscribe(to: outputs.itemList)

        let itemList = try XCTUnwrap(try itemListOutput.pollOnlyValue())
        XCTAssertEqual(itemList.count, 4)
        XCTAssertEqual(itemList.activeItemIndex, 2)
        XCTAssertEqual(itemList[itemAt: 0], .from(playbackQueue.stateValue.history[0]))
        XCTAssertEqual(itemList[itemAt: 1], .from(removedItem))
        XCTAssertEqual(itemList[itemAt: 2], .from(playbackQueue.stateValue.activeItem!))
        XCTAssertEqual(itemList[itemAt: 3], .from(playbackQueue.stateValue.upNext[0]))
        XCTAssertEqual(itemList.transition, .movedForward)
    }

    func test_itemListOutput_withMovedToPreviousItemContext() throws {
        let playbackQueue = MockPlaybackQueue()

        let removedItem = PlaybackQueueItem(song: .mock())

        playbackQueue.stateValue = .init(
            history: [.init(song: .mock())],
            activeItem: .init(song: .mock()),
            upNext: [.init(song: .mock())],
            context: .movedToPreviousItem(removedItem: removedItem)
        )

        let sut = PlayerStageViewModel(playbackQueue: playbackQueue)

        let outputs = sut.bind(inputs: .init(
            stoppedOnItemAtIndex: .never(),
            willBeginDragging: .never()
        ))

        let itemListOutput = TestSubscriber.subscribe(to: outputs.itemList)

        let itemList = try XCTUnwrap(try itemListOutput.pollOnlyValue())
        XCTAssertEqual(itemList.count, 4)
        XCTAssertEqual(itemList.activeItemIndex, 1)
        XCTAssertEqual(itemList[itemAt: 0], .from(playbackQueue.stateValue.history[0]))
        XCTAssertEqual(itemList[itemAt: 1], .from(playbackQueue.stateValue.activeItem!))
        XCTAssertEqual(itemList[itemAt: 2], .from(removedItem))
        XCTAssertEqual(itemList[itemAt: 3], .from(playbackQueue.stateValue.upNext[0]))
        XCTAssertEqual(itemList.transition, .movedBackward)
    }

    func test_itemListOutput_emitsWithoutPlaceholderItems_uponWillBeginDragging() throws {
        let playbackQueue = MockPlaybackQueue()

        playbackQueue.stateValue = .init(
            activeItem: .init(song: .mock()),
            context: .movedToNextItem(removedItem: .init(song: .mock()))
        )

        let sut = PlayerStageViewModel(playbackQueue: playbackQueue)

        let willBeginDragging = TestPublisher<Void, Never>()

        let outputs = sut.bind(inputs: .init(
            stoppedOnItemAtIndex: .never(),
            willBeginDragging: willBeginDragging.eraseToAnyPublisher()
        ))

        let itemListOutput = TestSubscriber.subscribe(to: outputs.itemList)

        var itemList = try XCTUnwrap(try itemListOutput.pollOnlyValue())
        XCTAssertEqual(itemList.count, 2)
        XCTAssertEqual(itemList.transition, .movedForward)

        willBeginDragging.send()

        itemList = try XCTUnwrap(try itemListOutput.pollOnlyValue())
        XCTAssertEqual(itemList.count, 1)
        XCTAssertEqual(itemList.transition, nil)
    }

    func test_itemListOutput_emitsWithoutPlaceholderItems_uponStoppedOnItemAtIndex_withActiveItemIndex() throws {
        let playbackQueue = MockPlaybackQueue()

        playbackQueue.stateValue = .init(
            activeItem: .init(song: .mock()),
            upNext: Array(repeating: (), count: 5).map { .init(song: .mock()) },
            context: .movedToPreviousItem(removedItem: .init(song: .mock()))
        )

        let sut = PlayerStageViewModel(playbackQueue: playbackQueue)

        let stoppedOnItemAtIndex = TestPublisher<(index: Int, itemList: PlayerStageViewModel.ItemList), Never>()

        let outputs = sut.bind(inputs: .init(
            stoppedOnItemAtIndex: stoppedOnItemAtIndex.eraseToAnyPublisher(),
            willBeginDragging: .never()
        ))

        let itemListOutput = TestSubscriber.subscribe(to: outputs.itemList)

        var itemList = try XCTUnwrap(try itemListOutput.pollOnlyValue())
        XCTAssertEqual(itemList.count, 7)
        XCTAssertEqual(itemList.transition, .movedBackward)
        XCTAssertEqual(itemList.activeItemIndex, 0)

        // stop on an index other than the active item index:
        stoppedOnItemAtIndex.send((index: 5, itemList: itemList))

        XCTAssertTrue(itemListOutput.pollValues().isEmpty)

        // stop on the active item index:
        stoppedOnItemAtIndex.send((index: 0, itemList: itemList))

        itemList = try XCTUnwrap(try itemListOutput.pollOnlyValue())
        XCTAssertEqual(itemList.count, 6)
        XCTAssertEqual(itemList.transition, nil)
    }
}
