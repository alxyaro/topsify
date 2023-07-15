// Created by Alex Yaro on 2023-07-13.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class QueueListViewModelTests: XCTestCase {

    func testOutput_content_reflectsPlaybackQueueState() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.stateValue.activeItem = .init(song: .mock())
        playbackQueue.stateValue.userQueue = [.init(song: .mock())]
        playbackQueue.stateValue.upNext = [.init(song: .mock())]

        let viewModel = QueueListViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: .init())

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

        let outputs = viewModel.bind(inputs: .init())

        let sourceNameSubscriber = TestSubscriber.subscribe(to: outputs.sourceName)

        XCTAssertEqual(sourceNameSubscriber.pollValues(), ["Home"])
    }
}
