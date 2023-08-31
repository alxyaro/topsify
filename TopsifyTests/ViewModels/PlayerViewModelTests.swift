// Created by Alex Yaro on 2023-07-04.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class PlayerViewModelTests: XCTestCase {

    func testInput_tappedQueueButton_sendOutput_presentQueue() {
        let viewModel = PlayerViewModel(dependencies: .init(playbackQueue: MockPlaybackQueue()))

        let tappedQueueButtonPublisher = TestPublisher<Void, Never>()

        let outputs = viewModel.bind(inputs: .mock(
            tappedQueueButton: tappedQueueButtonPublisher.eraseToAnyPublisher()
        ))

        let presentQueue = TestSubscriber.subscribe(to: outputs.presentQueue)

        XCTAssertEqual(presentQueue.pollValues().count, 0)

        tappedQueueButtonPublisher.send()

        XCTAssertEqual(presentQueue.pollValues().count, 1)
    }

    func testOutput_backgroundGradient_derivedFromActiveItemOfPlaybackQueue() throws {
        let accentColor = HexColor("#d6121e")
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.stateValue.activeItem = .init(song: .mock(accentColor: accentColor))

        let viewModel = PlayerViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: .mock())

        let backgroundGradientSubscriber = TestSubscriber.subscribe(to: outputs.backgroundGradient)
        let backgroundGradient = try backgroundGradientSubscriber.pollOnlyValue()

        XCTAssertEqual(backgroundGradient.top, accentColor.shaded(by: 0.2))
        XCTAssertEqual(backgroundGradient.bottom, accentColor.shaded(by: 0.7))
    }

    func testOutput_dismiss_derivedFromTopBarViewModel() {
        let viewModel = PlayerViewModel(dependencies: .init(playbackQueue: MockPlaybackQueue()))

        let tappedDismissButtonPublisher = TestPublisher<Void, Never>()

        _ = viewModel.topBarViewModel.bind(inputs: .mock(
            tappedDismissButton: tappedDismissButtonPublisher.eraseToAnyPublisher()
        ))

        let outputs = viewModel.bind(inputs: .mock())

        let dismiss = TestSubscriber.subscribe(to: outputs.dismiss)

        XCTAssertEqual(dismiss.pollValues().count, 0)

        tappedDismissButtonPublisher.send()

        XCTAssertEqual(dismiss.pollValues().count, 1)
    }
}

extension PlayerViewModel.Inputs {

    static func mock(
        tappedQueueButton: AnyPublisher<Void, Never> = .never()
    ) -> Self {
        .init(
            tappedQueueButton: tappedQueueButton
        )
    }
}
