// Created by Alex Yaro on 2023-07-19.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class SongListCellViewModelTests: XCTestCase {

    func testInput_tappedOptionsButton_callsOptionsButtonStateHandler() {
        var tapHandlerCalled = false
        let viewModel = SongListCellViewModel(song: .mock(), optionsButtonState: .shown(tapHandler: {
            tapHandlerCalled = true
        }))

        let tappedOptionsButton = TestPublisher<Void, Never>()

        _ = viewModel.bind(inputs: .init(
            tappedOptionsButton: tappedOptionsButton.eraseToAnyPublisher()
        ))

        XCTAssertFalse(tapHandlerCalled)

        tappedOptionsButton.send()

        XCTAssertTrue(tapHandlerCalled)
    }
}
