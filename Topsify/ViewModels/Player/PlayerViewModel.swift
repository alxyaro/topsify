// Created by Alex Yaro on 2023-04-22.

import Foundation

final class PlayerViewModel {
    private let dependencies: Dependencies

    let stageViewModel: PlayerStageViewModel
    let titleViewModel: PlayerTitleViewModel

    init(dependencies: Dependencies) {
        self.dependencies = dependencies

        self.stageViewModel = .init(playbackQueue: dependencies.playbackQueue)
        self.titleViewModel = .init(dependencies: .init(playbackQueue: dependencies.playbackQueue))
    }
}

// MARK: - Nested Types

extension PlayerViewModel {

    struct Dependencies {
        let playbackQueue: any PlaybackQueueType
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
