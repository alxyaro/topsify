// Created by Alex Yaro on 2023-06-30.

import Combine
import Foundation

final class PlayBarViewModel {
    private let dependencies: Dependencies
    private var disposeBag = DisposeBag()

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func bind(inputs: Inputs) -> Outputs {
        bind(inputs: inputs, playbackQueue: dependencies.playbackQueue)
    }

    private func bind(inputs: Inputs, playbackQueue: some PlaybackQueueType) -> Outputs {
        inputs.changedActiveItemIndex
            .flatMapLatest { rawIndex in
                playbackQueue.state
                    .map {
                        PlaybackQueueIndex.from(rawIndex: rawIndex, using: $0)
                    }
                    .prefix(1)
            }
            .unwrapped()
            .sink { index in
                playbackQueue.goToItem(atIndex: index)
            }
            .store(in: &disposeBag)

        return Outputs(
            itemList: playbackQueue.state
                .map(ItemList.init(state:))
                .eraseToAnyPublisher(),
            artworkURL: playbackQueue.state
                .compactMap {
                    $0[itemAt: .activeItem]?.song.imageURL
                }
                .eraseToAnyPublisher()
        )
    }
}

// MARK: - Nested Types

extension PlayBarViewModel {

    struct Dependencies {
        let playbackQueue: any PlaybackQueueType
    }

    struct Inputs {
        let changedActiveItemIndex: AnyPublisher<Int, Never>
    }

    struct Outputs {
        let itemList: AnyPublisher<ItemList, Never>
        let artworkURL: AnyPublisher<URL, Never>
    }

    struct ItemList {
        fileprivate let state: any PlaybackQueueState

        var activeIndex: Int? {
            state.activeItemIndex
        }
        var count: Int {
            state.count
        }

        subscript (_ rawIndex: Int) -> Item? {
            guard let index = PlaybackQueueIndex.from(rawIndex: rawIndex, using: state) else {
                return nil
            }
            return state[itemAt: index]
                .map {
                    Item(
                        title: $0.song.title,
                        subtitle: $0.song.artists.map(\.name).commaJoined()
                    )
                }
        }
    }

    struct Item {
        let title: String
        let subtitle: String
    }
}

// MARK: - Live Dependencies

extension PlayBarViewModel.Dependencies {

    static func live() -> Self {
        .init(
            playbackQueue: Environment.current.playbackQueue
        )
    }
}
