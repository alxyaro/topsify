// Created by Alex Yaro on 2023-07-07.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class PlayerTopBarViewModelTests: XCTestCase {

    func testInput_tappedDismissButton_callsDependency() {
        let tappedDismissButtonSubject = PassthroughSubject<Void, Never>()
        let viewModel = PlayerTopBarViewModel(dependencies: .mock(tappedDismissButtonSubject: tappedDismissButtonSubject))

        let tappedDismissButtonPublisher = TestPublisher<Void, Never>()

        _ = viewModel.bind(inputs: .mock(
            tappedDismissButton: tappedDismissButtonPublisher.eraseToAnyPublisher()
        ))

        let tappedDismissButton = TestSubscriber.subscribe(to: tappedDismissButtonSubject)

        XCTAssertEqual(tappedDismissButton.pollValues().count, 0)

        tappedDismissButtonPublisher.send()

        XCTAssertEqual(tappedDismissButton.pollValues().count, 1)
    }

    func testOutput_title_whenPlaybackQueueHasSource() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.sourceSubject.send(.album(.mock(title: "Best Album")))
        playbackQueue.stateValue.activeItem = .init(song: .mock(), isUserQueueItem: false)

        let viewModel = PlayerTopBarViewModel(dependencies: .mock(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: .mock())

        let title = try TestSubscriber.subscribe(to: outputs.title).pollOnlyValue()
        XCTAssertEqual(title, "Best Album")
    }

    func testOutput_title_whenPlaybackQueueItemIsQueueItem() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.sourceSubject.send(.album(.mock(title: "Best Album")))
        playbackQueue.stateValue.activeItem = .init(song: .mock(), isUserQueueItem: true)

        let viewModel = PlayerTopBarViewModel(dependencies: .mock(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: .mock())

        let title = try TestSubscriber.subscribe(to: outputs.title).pollOnlyValue()
        XCTAssertEqual(title, "Playing from Queue")
    }

    func testOutput_title_whenPlaybackQueueHasNoSource() throws {
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.sourceSubject.send(nil)
        playbackQueue.stateValue.activeItem = .init(song: .mock(), isUserQueueItem: false)

        let viewModel = PlayerTopBarViewModel(dependencies: .mock(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: .mock())

        let title = try TestSubscriber.subscribe(to: outputs.title).pollOnlyValue()
        XCTAssertEqual(title, nil)
    }
}

private extension PlayerTopBarViewModel.Dependencies {

    static func mock(
        playbackQueue: MockPlaybackQueue = .init(),
        tappedDismissButtonSubject: any Subject<Void, Never> = PassthroughSubject()
    ) -> Self {
        .init(
            playbackQueue: playbackQueue,
            tappedDismissButtonSubject: tappedDismissButtonSubject
        )
    }
}

extension PlayerTopBarViewModel.Inputs {

    static func mock(
        tappedDismissButton: AnyPublisher<Void, Never> = .never()
    ) -> Self {
        .init(
            tappedDismissButton: tappedDismissButton
        )
    }
}
