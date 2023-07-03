// Created by Alex Yaro on 2023-07-03.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class PlayBarViewModelTests: XCTestCase {

    func testInput_changedActiveItemIndex_callsPlaybackQueue() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.stateValue.activeItem = .init(song: .mock())
        playbackQueue.stateValue.upNext = [.init(song: .mock())]

        let viewModel = PlayBarViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let goToItemAtIndexSubscriber = TestSubscriber.subscribe(to: playbackQueue.goToItemAtIndexSubject)
        let changedActiveItemIndexPublisher = TestPublisher<Int, Never>()

        _ = viewModel.bind(inputs: .init(
            changedActiveItemIndex: changedActiveItemIndexPublisher.eraseToAnyPublisher()
        ))

        XCTAssert(goToItemAtIndexSubscriber.pollEvents().isEmpty)

        changedActiveItemIndexPublisher.send(0)
        changedActiveItemIndexPublisher.send(1)

        XCTAssertEqual(goToItemAtIndexSubscriber.pollValues().map(\.index), [.activeItem, .upNext(0)])

        changedActiveItemIndexPublisher.send(-1)
        changedActiveItemIndexPublisher.send(2)

        XCTAssert(goToItemAtIndexSubscriber.pollEvents().isEmpty)
    }

    func testOutput_itemList_matchesPlaybackQueueState_withEmptyState() throws {
        let playbackQueue = MockPlaybackQueue()

        let viewModel = PlayBarViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: .init(
            changedActiveItemIndex: .never()
        ))

        let itemListSubscriber = TestSubscriber.subscribe(to: outputs.itemList)
        let itemList = try itemListSubscriber.pollOnlyValue()

        XCTAssertEqual(itemList.count, 0)
        XCTAssertEqual(itemList.activeIndex, nil)
    }

    func testOutput_itemList_matchesPlaybackQueueState_withNonEmptyState() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.stateValue.history = [
            .init(
                song: .mock(
                    artists: [.mock(name: "Artist One")],
                    title: "Rehab"
                )
            )
        ]
        playbackQueue.stateValue.activeItem = .init(
            song: .mock(
                artists: [.mock(name: "Artist Two"), .mock(name: "Artist Three")],
                title: "Pluto to Mars"
            )
        )
        playbackQueue.stateValue.userQueue = [
            .init(
                song: .mock(
                    artists: [.mock(name: "Artist Four")],
                    title: "x2"
                )
            )
        ]
        playbackQueue.stateValue.upNext = [
            .init(
                song: .mock(
                    artists: [.mock(name: "Artist Four")],
                    title: "Days Come and Go"
                )
            )
        ]

        let viewModel = PlayBarViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: .init(
            changedActiveItemIndex: .never()
        ))

        let itemListSubscriber = TestSubscriber.subscribe(to: outputs.itemList)
        let itemList = try itemListSubscriber.pollOnlyValue()

        XCTAssertEqual(itemList.count, 4)
        XCTAssertEqual(itemList.activeIndex, 1)

        XCTAssertEqual(itemList[0], .init(title: "Rehab", subtitle: "Artist One"))
        XCTAssertEqual(itemList[1], .init(title: "Pluto to Mars", subtitle: "Artist Two, Artist Three"))
        XCTAssertEqual(itemList[2], .init(title: "x2", subtitle: "Artist Four"))
        XCTAssertEqual(itemList[3], .init(title: "Days Come and Go", subtitle: "Artist Four"))
    }

    func testOutput_artworkURL_derivedFromPlaybackQueueState() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.stateValue.activeItem = .init(song: .mock(imageURL: .imageMockWithRandomID()))

        let viewModel = PlayBarViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: .init(
            changedActiveItemIndex: .never()
        ))

        let artworkURLSubscriber = TestSubscriber.subscribe(to: outputs.artworkURL)
        let artworkURL = try artworkURLSubscriber.pollOnlyValue()

        XCTAssertEqual(artworkURL, playbackQueue.stateValue.activeItem?.song.imageURL)
    }
}

extension PlayBarViewModel.Item: Equatable {

    public static func == (lhs: PlayBarViewModel.Item, rhs: PlayBarViewModel.Item) -> Bool {
        lhs.title == rhs.title &&
        lhs.subtitle == rhs.subtitle
    }
}
