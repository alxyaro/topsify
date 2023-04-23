// Created by Alex Yaro on 2023-04-23.

import Combine

final class PlayerControlsViewModel {
    private let dependencies: Dependencies
    private var disposeBag = DisposeBag()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func bind(inputs: Inputs) -> Outputs {
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

        return Outputs()
    }
}

// MARK: - Nested Types

extension PlayerControlsViewModel {

    struct Dependencies {
        let playbackQueue: any PlaybackQueueType
    }

    struct Inputs {
        let tappedNextButton: AnyPublisher<Void, Never>
        let tappedPreviousButton: AnyPublisher<Void, Never>
    }

    typealias Outputs = Void
}
