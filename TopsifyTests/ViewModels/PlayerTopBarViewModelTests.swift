// Created by Alex Yaro on 2023-07-07.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class PlayerTopBarViewModelTests: XCTestCase {

    func testOutput_title_whenPlaybackQueueHasSource() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.sourceSubject.send(.album(.mock(title: "Best Album")))
        playbackQueue.stateValue.activeItem = .init(song: .mock(), isUserQueueItem: false)

        let viewModel = PlayerTopBarViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: ())

        let title = try TestSubscriber.subscribe(to: outputs.title).pollOnlyValue()
        XCTAssertEqual(title, "Best Album")
    }

    func testOutput_title_whenPlaybackQueueItemIsQueueItem() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.sourceSubject.send(.album(.mock(title: "Best Album")))
        playbackQueue.stateValue.activeItem = .init(song: .mock(), isUserQueueItem: true)

        let viewModel = PlayerTopBarViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: ())

        let title = try TestSubscriber.subscribe(to: outputs.title).pollOnlyValue()
        XCTAssertEqual(title, "Playing from Queue")
    }

    func testOutput_title_whenPlaybackQueueHasNoSource() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.sourceSubject.send(nil)
        playbackQueue.stateValue.activeItem = .init(song: .mock(), isUserQueueItem: false)

        let viewModel = PlayerTopBarViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: ())

        let title = try TestSubscriber.subscribe(to: outputs.title).pollOnlyValue()
        XCTAssertEqual(title, nil)
    }
}
