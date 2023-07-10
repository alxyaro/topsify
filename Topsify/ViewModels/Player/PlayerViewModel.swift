// Created by Alex Yaro on 2023-04-22.

import Combine
import DynamicColor
import Foundation

final class PlayerViewModel {
    private let dependencies: Dependencies

    let topBarViewModel: PlayerTopBarViewModel
    let stageViewModel: PlayerStageViewModel
    let titleViewModel: PlayerTitleViewModel
    let controlsViewModel: PlayerControlsViewModel

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        self.topBarViewModel = .init(dependencies: .init(playbackQueue: dependencies.playbackQueue))
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
                .compactMap { $0[itemAt: .activeItem]?.song.accentColorHex }
                .map { accentColorHex in
                    return (
                        top: HexColor(accentColorHex, shadedBy: 0.2),
                        bottom: HexColor(accentColorHex, shadedBy: 0.7)
                    )
                }
                .eraseToAnyPublisher()
        )
    }
}

// MARK: - Nested Types

extension PlayerViewModel {

    struct Dependencies {
        let playbackQueue: any PlaybackQueueType
    }

    typealias Inputs = Void

    struct Outputs {
        let backgroundGradient: AnyPublisher<(top: HexColor, bottom: HexColor), Never>
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
