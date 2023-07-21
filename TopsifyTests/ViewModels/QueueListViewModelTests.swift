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
        playbackQueue.sourceSubject.value = .song(.mock(title: "Home"))

        let viewModel = QueueListViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: .mock())

        let sourceNameSubscriber = TestSubscriber.subscribe(to: outputs.sourceName)

        XCTAssertEqual(sourceNameSubscriber.pollValues(), ["Home"])
    }
}

private extension QueueListViewModel.Inputs {

    static func mock(
        movedItem: AnyPublisher<QueueListViewModel.ItemMovement, Never> = .never()
    ) -> Self {
        .init(movedItem: movedItem)
    }
}

extension QueueListViewModel.Content: Equatable {

    public static func == (lhs: Topsify.QueueListViewModel.Content, rhs: Topsify.QueueListViewModel.Content) -> Bool {
        lhs.nowPlaying?.id == rhs.nowPlaying?.id &&
        lhs.nextInQueue.map(\.id) == rhs.nextInQueue.map(\.id) &&
        lhs.nextFromSource.map(\.id) == rhs.nextFromSource.map(\.id)
    }
}
