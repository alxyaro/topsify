// Created by Alex Yaro on 2023-07-04.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class PlayerViewModelTests: XCTestCase {

    func testOutput_backgroundGradient_derivedFromActiveItemOfPlaybackQueue() throws {
        let accentColorHex = "#d6121e"
        let playbackQueue = MockPlaybackQueue()
        playbackQueue.stateValue.activeItem = .init(song: .mock(accentColorHex: accentColorHex))

        let viewModel = PlayerViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = viewModel.bind(inputs: ())

        let backgroundGradientSubscriber = TestSubscriber.subscribe(to: outputs.backgroundGradient)
        let backgroundGradient = try backgroundGradientSubscriber.pollOnlyValue()

        XCTAssertEqual(backgroundGradient.top, HexColor(accentColorHex, shadedBy: 0.2))
        XCTAssertEqual(backgroundGradient.bottom, HexColor(accentColorHex, shadedBy: 0.7))
    }

    func testOutput_dismiss_derivedFromTopBarViewModel() {
        let viewModel = PlayerViewModel(dependencies: .init(playbackQueue: MockPlaybackQueue()))

        let tappedDismissButtonPublisher = TestPublisher<Void, Never>()

        _ = viewModel.topBarViewModel.bind(inputs: .mock(
            tappedDismissButton: tappedDismissButtonPublisher.eraseToAnyPublisher()
        ))

        let outputs = viewModel.bind(inputs: ())

        let dismiss = TestSubscriber.subscribe(to: outputs.dismiss)

        XCTAssertEqual(dismiss.pollValues().count, 0)

        tappedDismissButtonPublisher.send()

        XCTAssertEqual(dismiss.pollValues().count, 1)
    }
}
