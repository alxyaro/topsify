// Created by Alex Yaro on 2023-04-22.

import Combine
import DynamicColor
import Foundation

final class PlayerViewModel {

    let topBarViewModel: PlayerTopBarViewModel
    let stageViewModel: PlayerStageViewModel
    let titleViewModel: PlayerTitleViewModel
    let controlsViewModel: PlayerControlsViewModel

    private let dependencies: Dependencies
    private let tappedDismissButtonSubject = PassthroughSubject<Void, Never>()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        self.topBarViewModel = .init(dependencies: .init(
            playbackQueue: dependencies.playbackQueue,
            tappedDismissButtonSubject: tappedDismissButtonSubject
        ))
        self.stageViewModel = .init(playbackQueue: dependencies.playbackQueue)
        self.titleViewModel = .init(dependencies: .init(playbackQueue: dependencies.playbackQueue))
        self.controlsViewModel = .init(dependencies: .init(playbackQueue: dependencies.playbackQueue))
    }

    func bind(inputs: Inputs) -> Outputs {
        bind(inputs: inputs, playbackQueue: dependencies.playbackQueue)
    }

    private func bind(inputs: Inputs, playbackQueue: some PlaybackQueueType) -> Outputs {
        return Outputs(
            backgroundGradient: playbackQueue.state
                .compactMap { $0[itemAt: .activeItem]?.song.accentColor }
                .map { accentColor in
                    return (
                        top: accentColor.shaded(by: 0.2),
                        bottom: accentColor.shaded(by: 0.7)
                    )
                }
                .eraseToAnyPublisher(),
            presentQueue: inputs.tappedQueueButton,
            dismiss: tappedDismissButtonSubject
                .eraseToAnyPublisher()
        )
    }
}

// MARK: - Nested Types

extension PlayerViewModel {

    struct Dependencies {
        let playbackQueue: any PlaybackQueueType
    }

    struct Inputs {
        let tappedQueueButton: AnyPublisher<Void, Never>
    }

    struct Outputs {
        let backgroundGradient: AnyPublisher<(top: HexColor, bottom: HexColor), Never>
        let presentQueue: AnyPublisher<Void, Never>
        let dismiss: AnyPublisher<Void, Never>
    }
}

// MARK: - Live Dependencies

extension PlayerViewModel.Dependencies {

    static func live() -> Self {
        .init(
            playbackQueue: Environment.current.playbackQueue
        )
    }
}
