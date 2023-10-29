// Created by Alex Yaro on 2023-07-13.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class QueueListViewModelTests: XCTestCase {

    func testInput_movedItem_callsPlaybackQueue() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.stateValue.activeItem = .init(song: .mock())
        playbackQueue.stateValue.userQueue = [.init(song: .mock())]
        playbackQueue.stateValue.upNext = [.init(song: .mock())]

        let viewModel = QueueListViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let movedItemPublisher = TestPublisher<QueueListViewModel.ItemMovement, Never>()

        _ = viewModel.bind(inputs: .mock(
            movedItem: movedItemPublisher.eraseToAnyPublisher()
        ))

        var moveItemFromToEvents = [(PlaybackQueueIndex, PlaybackQueueIndex)]()
        playbackQueue.moveItemFromToCallback = {
            moveItemFromToEvents.append(($0, $1))
            return false
        }

        XCTAssertTrue(moveItemFromToEvents.isEmpty)

        movedItemPublisher.send((from: .nextFromSource(index: 0), to: .nextInQueue(index: 1)))

        XCTAssertEqual(moveItemFromToEvents.count, 1)
        XCTAssertEqual(moveItemFromToEvents[0].0, .upNext(0))
        XCTAssertEqual(moveItemFromToEvents[0].1, .userQueue(1))
    }

    func testInput_movedItem_causesContentReEmission_ifPlaybackQueueMoveFails() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.moveItemFromToCallback = { _, _ in false }

        let movedItemPublisher = TestPublisher<QueueListViewModel.ItemMovement, Never>()

        let viewModel = QueueListViewModel(dependencies: .init(playbackQueue: playbackQueue))
        let outputs = viewModel.bind(inputs: .mock(
            movedItem: movedItemPublisher.eraseToAnyPublisher()
        ))

        let contentSubscriber = TestSubscriber.subscribe(to: outputs.content)
        let content = try contentSubscriber.pollOnlyValue()

        movedItemPublisher.send((from: .nextFromSource(index: 300), to: .nextInQueue(index: -100)))

        XCTAssertEqual(try contentSubscriber.pollOnlyValue(), content)
    }

    func testInput_selectedItemIndices_updatesProperty_hasSelectedItems() {
        let viewModel = QueueListViewModel(dependencies: .init(playbackQueue: MockPlaybackQueue()))

        let selectedItemIndicesPublisher = TestPublisher<[QueueListViewModel.ItemIndex], Never>()

        _ = viewModel.bind(inputs: .mock(
            selectedItemIndices: selectedItemIndicesPublisher.eraseToAnyPublisher()
        ))

        let hasSelectedItems = TestSubscriber.subscribe(to: viewModel.hasSelectedItems)

        XCTAssertEqual(hasSelectedItems.pollValues(), [false])

        selectedItemIndicesPublisher.send([])

        XCTAssertEqual(hasSelectedItems.pollValues(), [])

        selectedItemIndicesPublisher.send([
            .nextFromSource(index: 0)
        ])

        XCTAssertEqual(hasSelectedItems.pollValues(), [true])

        selectedItemIndicesPublisher.send([])

        XCTAssertEqual(hasSelectedItems.pollValues(), [false])
    }

    func testInput_selectedItemIndices_updatesProperty_isQueueItemSelected() {
        let viewModel = QueueListViewModel(dependencies: .init(playbackQueue: MockPlaybackQueue()))

        let selectedItemIndicesPublisher = TestPublisher<[QueueListViewModel.ItemIndex], Never>()

        _ = viewModel.bind(inputs: .mock(
            selectedItemIndices: selectedItemIndicesPublisher.eraseToAnyPublisher()
        ))

        let isQueueItemSelected = TestSubscriber.subscribe(to: viewModel.isQueueItemSelected)

        XCTAssertEqual(isQueueItemSelected.pollValues(), [false])

        selectedItemIndicesPublisher.send([
            .nextFromSource(index: 0),
            .nextFromSource(index: 1)
        ])

        XCTAssertEqual(isQueueItemSelected.pollValues(), [])

        selectedItemIndicesPublisher.send([
            .nextFromSource(index: 0),
            .nextFromSource(index: 1),
            .nextInQueue(index: 1)
        ])

        XCTAssertEqual(isQueueItemSelected.pollValues(), [true])
    }

    func testInput_tappedItem_callsPlaybackQueue() {
        let playbackQueue = MockPlaybackQueue()
        let viewModel = QueueListViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let tappedItemPublisher = TestPublisher<QueueListViewModel.ItemIndex, Never>()

        _ = viewModel.bind(inputs: .mock(
            tappedItem: tappedItemPublisher.eraseToAnyPublisher()
        ))

        let goToItemAtIndex = TestSubscriber.subscribe(to: playbackQueue.goToItemAtIndexSubject)

        tappedItemPublisher.send(.nextFromSource(index: 5))

        XCTAssertEqual(goToItemAtIndex.pollValues().map(\.index), [.upNext(5)])
    }

    // TODO: testInput_tappedOptionsButtonAt_ ...

    func testDelegateMethod_selectionMenuRemoveButtonTapped_callsPlaybackQueue() {
        let playbackQueue = MockPlaybackQueue()
        let viewModel = QueueListViewModel(dependencies: .init(playbackQueue: playbackQueue))

        _ = viewModel.bind(inputs: .mock(
            selectedItemIndices: .just([
                .nextInQueue(index: 0),
                .nextFromSource(index: 0),
                .nextFromSource(index: 1)
            ])
        ))

        let removeItemsAtSubscriber = TestSubscriber.subscribe(to: playbackQueue.removeItemsAtSubject)

        viewModel.selectionMenuRemoveButtonTapped()

        XCTAssertEqual(removeItemsAtSubscriber.pollValues(), [
            [.userQueue(0), .upNext(0), .upNext(1)]
        ])
    }

    func testDelegateMethod_selectionMenuMoveToQueueButtonTapped_sendsOutput_and_callsPlaybackQueue() {
        let playbackQueue = MockPlaybackQueue()
        let viewModel = QueueListViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: .mock(
            selectedItemIndices: .just([
                .nextFromSource(index: 2)
            ])
        ))

        let deselectAllItemsSubscriber = TestSubscriber.subscribe(to: outputs.deselectAllItems)
        let moveItemsToQueueAtSubscriber = TestSubscriber.subscribe(to: playbackQueue.moveItemsToQueueAtSubject)

        viewModel.selectionMenuMoveToQueueButtonTapped()

        XCTAssertEqual(deselectAllItemsSubscriber.pollValues().count, 1)
        XCTAssertEqual(moveItemsToQueueAtSubscriber.pollValues(), [[.upNext(2)]])
    }

    func testOutput_content_reflectsPlaybackQueueState() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.stateValue.activeItem = .init(song: .mock())
        playbackQueue.stateValue.userQueue = [.init(song: .mock())]
        playbackQueue.stateValue.upNext = [.init(song: .mock())]

        let viewModel = QueueListViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: .mock())

        let contentSubscriber = TestSubscriber.subscribe(to: outputs.content)
        let content = try contentSubscriber.pollOnlyValue()

        XCTAssertEqual(content.nowPlaying?.id, playbackQueue.stateValue.activeItem?.id)
        XCTAssertEqual(content.nextInQueue.map(\.id), playbackQueue.stateValue.userQueue.map(\.id))
        XCTAssertEqual(content.nextFromSource.map(\.id), playbackQueue.stateValue.upNext.map(\.id))
    }

    func testOutput_sourceName_matchesPlaybackQueueSource() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.sourceSubject.value = .init(title: "Home", contentID: .mock())

        let viewModel = QueueListViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: .mock())

        let sourceNameSubscriber = TestSubscriber.subscribe(to: outputs.sourceName)

        XCTAssertEqual(sourceNameSubscriber.pollValues(), ["Home"])
    }
}

extension QueueListViewModel.Inputs {

    static func mock(
        movedItem: AnyPublisher<QueueListViewModel.ItemMovement, Never> = .never(),
        selectedItemIndices: AnyPublisher<[QueueListViewModel.ItemIndex], Never> = .never(),
        tappedItem: AnyPublisher<QueueListViewModel.ItemIndex, Never> = .never()
    ) -> Self {
        .init(
            movedItem: movedItem,
            selectedItemIndices: selectedItemIndices,
            tappedItem: tappedItem
        )
    }
}

extension QueueListViewModel.Content: Equatable {

    public static func == (lhs: Topsify.QueueListViewModel.Content, rhs: Topsify.QueueListViewModel.Content) -> Bool {
        lhs.nowPlaying?.id == rhs.nowPlaying?.id &&
        lhs.nextInQueue.map(\.id) == rhs.nextInQueue.map(\.id) &&
        lhs.nextFromSource.map(\.id) == rhs.nextFromSource.map(\.id)
    }
}
