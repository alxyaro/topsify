// Created by Alex Yaro on 2023-07-06.

import Combine
import Foundation

final class PlayerTopBarViewModel {
    private let dependencies: Dependencies
    private var disposeBag = DisposeBag()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func bind(inputs: Inputs) -> Outputs {
        bind(inputs: inputs, playbackQueue: dependencies.playbackQueue)
    }

    private func bind(inputs: Inputs, playbackQueue: some PlaybackQueueType) -> Outputs {
        inputs.tappedDismissButton
            .subscribe(dependencies.tappedDismissButtonSubject)
            .store(in: &disposeBag)

        return Outputs(
            title: Publishers.CombineLatest(
                playbackQueue.source,
                playbackQueue.state.map(\.activeItem)
            )
            .map { source, activeItem in
                if let activeItem, activeItem.isUserQueueItem {
                    return NSLocalizedString("Playing from Queue", comment: "Player title label when playing from the queue.")
                } else if let source {
                    return source.textValue
                } else {
                    return nil
                }
            }
                .removeDuplicates()
                .eraseToAnyPublisher()
        )
    }
}

// MARK: - Nested Types

extension PlayerTopBarViewModel {

    struct Dependencies {
        let playbackQueue: any PlaybackQueueType
        let tappedDismissButtonSubject: any Subject<Void, Never>
    }

    struct Inputs {
        let tappedDismissButton: AnyPublisher<Void, Never>
    }

    struct Outputs {
        let title: AnyPublisher<String?, Never>
    }
}
