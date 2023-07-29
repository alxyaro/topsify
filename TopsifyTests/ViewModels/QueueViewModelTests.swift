// Created by Alex Yaro on 2023-07-26.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class QueueViewModelTests: XCTestCase {

    func testOutputs_showPlaybackControls_showSelectionMenu_reflectListViewModel() {
        let viewModel = QueueViewModel(dependencies: .init(playbackQueue: MockPlaybackQueue()))

        let selectedItemIndicesPublisher = TestPublisher<[QueueListViewModel.ItemIndex], Never>()

        _ = viewModel.listViewModel.bind(inputs: .init(
            movedItem: .never(),
            selectedItemIndices: selectedItemIndicesPublisher.eraseToAnyPublisher(),
            tappedItem: .never(),
            tappedOptionsButtonAt: .never()
        ))

        let outputs = viewModel.bind(inputs: .init())

        let showPlaybackControls = TestSubscriber.subscribe(to: outputs.showPlaybackControls)
        let showSelectionMenu = TestSubscriber.subscribe(to: outputs.showSelectionMenu)

        XCTAssertEqual(try showPlaybackControls.pollOnlyValue(), true)
        XCTAssertEqual(try showSelectionMenu.pollOnlyValue(), false)

        selectedItemIndicesPublisher.send([.nextFromSource(index: 0)])

        XCTAssertEqual(try showPlaybackControls.pollOnlyValue(), false)
        XCTAssertEqual(try showSelectionMenu.pollOnlyValue(), true)

        selectedItemIndicesPublisher.send([.nextFromSource(index: 0), .nextFromSource(index: 1)])

        XCTAssertTrue(showPlaybackControls.pollValues().isEmpty)
        XCTAssertTrue(showSelectionMenu.pollValues().isEmpty)

        selectedItemIndicesPublisher.send([])

        XCTAssertEqual(try showPlaybackControls.pollOnlyValue(), true)
        XCTAssertEqual(try showSelectionMenu.pollOnlyValue(), false)
    }
}
