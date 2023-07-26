// Created by Alex Yaro on 2023-07-25.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class QueueSelectionMenuViewModelTests: XCTestCase {

    func testInput_tappedRemoveButton_callsDelegateMethod() {
        let delegate = MockDelegate()
        let viewModel = ViewModel(
            dependencies: .init(isQueueItemSelected: .never()),
            delegate: delegate
        )

        let tappedRemoveButtonPublisher = TestPublisher<Void, Never>()

        _ = viewModel.bind(inputs: .init(
            tappedRemoveButton: tappedRemoveButtonPublisher.eraseToAnyPublisher(),
            tappedMoveToQueueButton: .never()
        ))

        XCTAssertEqual(delegate.selectionMenuRemoveButtonTappedCallCount, 0)

        tappedRemoveButtonPublisher.send()

        XCTAssertEqual(delegate.selectionMenuRemoveButtonTappedCallCount, 1)
    }

    func testInput_tappedMoveToQueueButton_callsDelegateMethod() {
        let delegate = MockDelegate()
        let viewModel = ViewModel(
            dependencies: .init(isQueueItemSelected: .never()),
            delegate: delegate
        )

        let tappedMoveToQueueButtonPublisher = TestPublisher<Void, Never>()

        _ = viewModel.bind(inputs: .init(
            tappedRemoveButton: .never(),
            tappedMoveToQueueButton: tappedMoveToQueueButtonPublisher.eraseToAnyPublisher()
        ))

        XCTAssertEqual(delegate.selectionMenuMoveToQueueButtonTappedCallCount, 0)

        tappedMoveToQueueButtonPublisher.send()

        XCTAssertEqual(delegate.selectionMenuMoveToQueueButtonTappedCallCount, 1)
    }

    func testOutput_showMoveToQueueButton_derivedFromDependency() {
        let isQueueItemSelectedPublisher = TestPublisher<Bool, Never>()

        let delegate = MockDelegate()
        let viewModel = ViewModel(
            dependencies: .init(
                isQueueItemSelected: isQueueItemSelectedPublisher.eraseToAnyPublisher()
            ),
            delegate: delegate
        )

        let outputs = viewModel.bind(inputs: .init(
            tappedRemoveButton: .never(),
            tappedMoveToQueueButton: .never()
        ))
        let showMoveToQueueButton = TestSubscriber.subscribe(to: outputs.showMoveToQueueButton)

        XCTAssertTrue(showMoveToQueueButton.pollEvents().isEmpty)

        isQueueItemSelectedPublisher.send(true)

        XCTAssertEqual(showMoveToQueueButton.pollValues(), [false])

        isQueueItemSelectedPublisher.send(false)
        isQueueItemSelectedPublisher.send(true)

        XCTAssertEqual(showMoveToQueueButton.pollValues(), [true, false])
    }

    // MARK: - Helpers

    typealias ViewModel = QueueSelectionMenuViewModel

    class MockDelegate: QueueSelectionMenuViewModelDelegate {
        var selectionMenuRemoveButtonTappedCallCount = 0
        var selectionMenuMoveToQueueButtonTappedCallCount = 0

        func selectionMenuRemoveButtonTapped() {
            selectionMenuRemoveButtonTappedCallCount += 1
        }

        func selectionMenuMoveToQueueButtonTapped() {
            selectionMenuMoveToQueueButtonTappedCallCount += 1
        }
    }
}
