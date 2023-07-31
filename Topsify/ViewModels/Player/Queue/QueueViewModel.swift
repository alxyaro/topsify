// Created by Alex Yaro on 2023-07-24.

import Combine
import Foundation

final class QueueViewModel {
    let topBarViewModel: PlayerTopBarViewModel
    let listViewModel: QueueListViewModel
    let selectionMenuViewModel: QueueSelectionMenuViewModel

    private let dependencies: Dependencies
    private let tappedDismissButtonSubject = PassthroughSubject<Void, Never>()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        topBarViewModel = .init(
            dependencies: .init(
                playbackQueue: dependencies.playbackQueue,
                tappedDismissButtonSubject: tappedDismissButtonSubject
            )
        )
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
                .eraseToAnyPublisher(),
            dismiss: tappedDismissButtonSubject
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
        let dismiss: AnyPublisher<Void, Never>
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
