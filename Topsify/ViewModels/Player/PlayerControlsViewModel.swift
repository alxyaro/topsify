// Created by Alex Yaro on 2023-04-23.

import Combine

final class PlayerControlsViewModel {
    private let dependencies: Dependencies
    private var disposeBag = DisposeBag()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func bind(inputs: Inputs) -> Outputs {
        inputs.tappedPlayButton
            .sink(receiveValue: dependencies.playbackManager.play)
            .store(in: &disposeBag)

        inputs.tappedPauseButton
            .sink(receiveValue: dependencies.playbackManager.pause)
            .store(in: &disposeBag)

        inputs.tappedNextButton
            .sink { [dependencies] in
                dependencies.playbackQueue.goToNextItem()
            }
            .store(in: &disposeBag)

        inputs.tappedPreviousButton
            .sink { [dependencies] in
                dependencies.playbackQueue.goToPreviousItem()
            }
            .store(in: &disposeBag)

        return Outputs(
            isPlaying: dependencies.playbackManager.statusPublisher
                .map { $0 == .playing }
                .eraseToAnyPublisher()
        )
    }
}

// MARK: - Nested Types

extension PlayerControlsViewModel {

    struct Dependencies {
        let playbackQueue: any PlaybackQueueType
        let playbackManager: any PlaybackManagerType
    }

    struct Inputs {
        let tappedPlayButton: AnyPublisher<Void, Never>
        let tappedPauseButton: AnyPublisher<Void, Never>
        let tappedNextButton: AnyPublisher<Void, Never>
        let tappedPreviousButton: AnyPublisher<Void, Never>
    }

    struct Outputs {
        let isPlaying: AnyPublisher<Bool, Never>
    }
}
