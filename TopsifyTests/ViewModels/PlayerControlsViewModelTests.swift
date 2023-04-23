// Created by Alex Yaro on 2023-04-23.

@testable import Topsify
import Combine
import TestHelpers
import XCTest

final class PlayerControlsViewModelTests: XCTestCase {

    func testInput_tappedNextButton_callsPlaybackQueue() {
        let playbackQueue = MockPlaybackQueue()
        let sut = PlayerControlsViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let tappedNextButton = TestPublisher<Void, Never>()

        sut.bind(inputs: .init(
            tappedNextButton: tappedNextButton.eraseToAnyPublisher(),
            tappedPreviousButton: .never()
        ))

        let goToNextItem = TestSubscriber.subscribe(to: playbackQueue.goToNextItemSubject)

        XCTAssertEqual(goToNextItem.pollValues().count, 0)

        tappedNextButton.send()

        XCTAssertEqual(goToNextItem.pollValues().count, 1)
    }

    func testInput_tappedPreviousButton_callsPlaybackQueue() {
        let playbackQueue = MockPlaybackQueue()
        let sut = PlayerControlsViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let tappedPreviousButton = TestPublisher<Void, Never>()

        sut.bind(inputs: .init(
            tappedNextButton: .never(),
            tappedPreviousButton: tappedPreviousButton.eraseToAnyPublisher()
        ))

        let goToPreviousItem = TestSubscriber.subscribe(to: playbackQueue.goToPreviousItemSubject)

        XCTAssertEqual(goToPreviousItem.pollValues().count, 0)

        tappedPreviousButton.send()

        XCTAssertEqual(goToPreviousItem.pollValues().count, 1)
    }
}
