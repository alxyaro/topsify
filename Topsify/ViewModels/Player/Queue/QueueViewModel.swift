// Created by Alex Yaro on 2023-07-24.

import Combine
import Foundation

final class QueueViewModel {
    let listViewModel: QueueListViewModel
    let selectionMenuViewModel: QueueSelectionMenuViewModel

    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        listViewModel = .init(
            dependencies: .init(
                playbackQueue: dependencies.playbackQueue
            )
        )
        selectionMenuViewModel = .init(
            dependencies: .init(
                isQueueItemSelected: listViewModel.isQueueItemSelected
            ),
            delegate: listViewModel
        )
    }

    func bind(inputs: Inputs) -> Outputs {

        return Outputs(
            showPlaybackControls: listViewModel
                .hasSelectedItems
                .map(!)
                .eraseToAnyPublisher(),
            showSelectionMenu: listViewModel
                .hasSelectedItems
                .eraseToAnyPublisher()
        )
    }
}

// MARK: - Nested Types

extension QueueViewModel {

    struct Dependencies {
        let playbackQueue: any PlaybackQueueType
    }

    struct Inputs {

    }

    struct Outputs {
        let showPlaybackControls: AnyPublisher<Bool, Never>
        let showSelectionMenu: AnyPublisher<Bool, Never>
    }
}

// MARK: - Live Dependencies

extension QueueViewModel.Dependencies {

    static func live() -> Self {
        .init(
            playbackQueue: Environment.current.playbackQueue
        )
    }
}
