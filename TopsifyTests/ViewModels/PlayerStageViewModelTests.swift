// Created by Alex Yaro on 2023-04-21.

@testable import Topsify
import Combine
import TestHelpers
import XCTest

final class PlayerStageViewModelTests: XCTestCase {

    func test_itemList_reflectsPlaybackQueueState() throws {
        let playbackQueue = MockPlaybackQueue()
        let sut = PlayerStageViewModel(playbackQueue: playbackQueue)

        let itemList = TestSubscriber.subscribe(to: sut.itemList)

        XCTAssertNil(try itemList.pollOnlyValue())

        var state = playbackQueue.stateSubject.value
        state.activeItem = .init(song: .mock(imageURL: .imageMock(token: "image_active")))
        state.upNext = (0..<2).map { PlaybackQueueItem(song: .mock(imageURL: .imageMock(token: "image_upNext_\($0)"))) }
        playbackQueue.stateSubject.send(state)

        let itemListObj = try XCTUnwrap(try itemList.pollOnlyValue())
        XCTAssertEqual(itemListObj.count, 3)
        XCTAssertEqual(itemListObj[itemAt: 0], .init(
            artworkURL: .imageMock(token: "image_active")
        ))
        XCTAssertEqual(itemListObj[itemAt: 1], .init(
            artworkURL: .imageMock(token: "image_upNext_0")
        ))
        XCTAssertEqual(itemListObj[itemAt: 2], .init(
            artworkURL: .imageMock(token: "image_upNext_1")
        ))
    }

    func test_itemList_isNilWhenNoActiveItemInPlaybackQueue() {
        let playbackQueue = MockPlaybackQueue()

        var state = playbackQueue.stateSubject.value
        state.activeItem = nil
        playbackQueue.stateSubject.send(state)

        let sut = PlayerStageViewModel(playbackQueue: playbackQueue)

        let itemList = TestSubscriber.subscribe(to: sut.itemList)

        XCTAssertNil(try itemList.pollOnlyValue())
    }

    func test_movedToItemAtIndex_callsPlaybackQueue() throws {
        let playbackQueue = MockPlaybackQueue()
        let sut = PlayerStageViewModel(playbackQueue: playbackQueue)

        var state = playbackQueue.stateSubject.value
        state.activeItem = .init(song: .mock())
        state.upNext = Array(repeating: (), count: 3).map { PlaybackQueueItem(song: .mock()) }
        playbackQueue.stateSubject.send(state)

        let itemList = TestSubscriber.subscribe(to: sut.itemList)
        let goToItemAtIndex = TestSubscriber.subscribe(to: playbackQueue.goToItemAtIndexSubject)

        let itemListObj = try XCTUnwrap(try itemList.pollOnlyValue())

        sut.movedToItem(atIndex: 3, itemList: itemListObj)

        XCTAssertEqual(try goToItemAtIndex.pollOnlyValue(), .from(rawIndex: 3, using: state)!)
    }
}
