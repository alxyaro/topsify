// Created by Alex Yaro on 2024-01-01.

import Combine
import Foundation

final class PlayerSliderViewModel {
    private let dependencies: Dependencies
    private var disposeBag = DisposeBag()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func bind(inputs: Inputs) -> Outputs {

        inputs.movedThumbToPercentage
            .sink { [dependencies] value in
                guard let playbackTiming = dependencies.playbackManager.timing else {
                    return
                }
                let targetDuration = playbackTiming.duration * value.clamped(to: 0...1)

                // Disregard time changes of very small magnitudes:
                guard abs(targetDuration - playbackTiming.elapsedDuration) > 0.1 else { return }

                dependencies.playbackManager.seek(to: targetDuration)
            }
            .store(in: &disposeBag)

        return Outputs(
            thumbPositionPercentage: dependencies.playbackManager.timingPublisher
                .map { $0.map { $0.elapsedDuration / $0.duration } }
                .eraseToAnyPublisher(),
            songDuration: dependencies.playbackManager.timingPublisher
                .map(\.?.duration)
                .eraseToAnyPublisher(),
            elapsedSongDuration: dependencies.playbackManager.timingPublisher
                .map(\.?.elapsedDuration)
                .eraseToAnyPublisher()
        )
    }
}

// MARK: - Nested Types

extension PlayerSliderViewModel {

    struct Dependencies {
        let playbackManager: any PlaybackManagerType
    }

    struct Inputs {
        let movedThumbToPercentage: AnyPublisher<Double, Never>
    }

    struct Outputs {
        let thumbPositionPercentage: AnyPublisher<Double?, Never>
        let songDuration: AnyPublisher<TimeInterval?, Never>
        let elapsedSongDuration: AnyPublisher<TimeInterval?, Never>
    }
}
