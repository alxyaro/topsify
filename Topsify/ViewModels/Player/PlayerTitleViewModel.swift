// Created by Alex Yaro on 2023-04-22.

import Combine
import Foundation

final class PlayerTitleViewModel {
    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func bind(inputs: Void) -> Outputs {

        func activeItemPublisher(from playbackQueue: some PlaybackQueueType) -> AnyPublisher<PlaybackQueueItem?, Never> {
            playbackQueue.state.map(\.activeItem).eraseToAnyPublisher()
        }
        let activeItem = activeItemPublisher(from: dependencies.playbackQueue)

        return Outputs(
            title: activeItem.map { $0?.song.title ?? "" }.eraseToAnyPublisher(),
            artists: activeItem.map { item in
                if let item {
                    let separator = NSLocalizedString(", ", comment: "Separator for artists list")
                    return item.song.artists.map(\.name).joined(separator: separator)
                } else {
                    return ""
                }
            }.eraseToAnyPublisher()
        )
    }
}

// MARK: - Nested Types

extension PlayerTitleViewModel {

    struct Dependencies {
        let playbackQueue: any PlaybackQueueType
    }

    struct Outputs {
        let title: AnyPublisher<String, Never>
        let artists: AnyPublisher<String, Never>
    }
}
