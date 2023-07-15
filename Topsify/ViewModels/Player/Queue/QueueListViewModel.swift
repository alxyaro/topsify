// Created by Alex Yaro on 2023-07-13.

import Combine
import Foundation

final class QueueListViewModel {
    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func bind(inputs: Inputs) -> Outputs {
        bind(inputs: inputs, playbackQueue: dependencies.playbackQueue)
    }

    private func bind(inputs: Inputs, playbackQueue: some PlaybackQueueType) -> Outputs {
        return Outputs(
            content: playbackQueue.state
                .map { state in
                    Content(
                        nowPlaying: state.activeItem.map { ListItem(id: $0.id, viewModel: .init(song: $0.song)) },
                        nextInQueue: state.userQueue.map { ListItem(id: $0.id, viewModel: .init(song: $0.song)) },
                        nextFromSource: state.upNext.prefix(100).map { ListItem(id: $0.id, viewModel: .init(song: $0.song)) }
                    )
                }
                .eraseToAnyPublisher(),
            sourceName: playbackQueue.source
                .map(\.?.textValue)
                .eraseToAnyPublisher()
        )
    }
}

// MARK: - Nested Types

extension QueueListViewModel {

    struct Dependencies {
        let playbackQueue: any PlaybackQueueType
    }

    struct Inputs {

    }

    struct Outputs {
        let content: AnyPublisher<Content, Never>
        let sourceName: AnyPublisher<String?, Never>
    }

    struct Content {
        let nowPlaying: ListItem?
        let nextInQueue: [ListItem]
        let nextFromSource: [ListItem]
    }

    struct ListItem: Identifiable {
        let id: UUID
        let viewModel: SongListCellViewModel
    }
}

// MARK: - Live Dependencies

extension QueueListViewModel.Dependencies {

    static func live() -> Self {
        .init(
            playbackQueue: Environment.current.playbackQueue
        )
    }
}
