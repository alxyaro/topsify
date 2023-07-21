// Created by Alex Yaro on 2023-07-13.

import Combine
import Foundation

final class QueueListViewModel {
    private let dependencies: Dependencies
    private var disposeBag = DisposeBag()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func bind(inputs: Inputs) -> Outputs {
        bind(inputs: inputs, playbackQueue: dependencies.playbackQueue)
    }

    private func bind(inputs: Inputs, playbackQueue: some PlaybackQueueType) -> Outputs {

        let resendState = CurrentValueSubject<Void, Never>(())

        inputs.movedItem
            .sink { from, to in
                let moveResult = playbackQueue.moveItem(from: from.playbackQueueIndex, to: to.playbackQueueIndex)
                if !moveResult {
                    resendState.send()
                }
            }
            .store(in: &disposeBag)

        return Outputs(
            content: playbackQueue.state
                .map { state in
                    Content(
                        nowPlaying: state.activeItem.map {
                            ListItem.from(
                                $0,
                                optionsButtonState: .shown {
                                    // TODO: handle options button tap
                                }
                            )
                        },
                        nextInQueue: state.userQueue.map { ListItem.from($0) },
                        nextFromSource: state.upNext.prefix(100).map { ListItem.from($0) }
                    )
                }
                .reEmit(onOutputFrom: resendState)
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
        let movedItem: AnyPublisher<ItemMovement, Never>
    }

    struct Outputs {
        let content: AnyPublisher<Content, Never>
        let sourceName: AnyPublisher<String?, Never>
    }

    typealias ItemMovement = (from: MovableItemIndex, to: MovableItemIndex)

    enum MovableItemIndex {
        case nextInQueue(index: Int)
        case nextFromSource(index: Int)

        fileprivate var playbackQueueIndex: PlaybackQueueIndex {
            switch self {
            case .nextInQueue(let index):
                return .userQueue(index)
            case .nextFromSource(let index):
                return .upNext(index)
            }
        }
    }

    struct Content {
        let nowPlaying: ListItem?
        let nextInQueue: [ListItem]
        let nextFromSource: [ListItem]
    }

    struct ListItem: Identifiable {
        let id: UUID
        let viewModel: SongListCellViewModel

        static func from(
            _ playbackQueueItem: PlaybackQueueItem,
            optionsButtonState: SongListCellViewModel.ButtonState = .hidden
        ) -> Self {
            .init(
                id: playbackQueueItem.id,
                viewModel: .init(
                    song: playbackQueueItem.song,
                    optionsButtonState: optionsButtonState
                )
            )
        }
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
