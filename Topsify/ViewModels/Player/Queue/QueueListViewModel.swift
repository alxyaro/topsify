// Created by Alex Yaro on 2023-07-13.

import Combine
import Foundation

final class QueueListViewModel {

    var hasSelectedItems: AnyPublisher<Bool, Never> {
        selectedItemIndicesSubject
            .map(\.isEmpty)
            .map(!)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    var isQueueItemSelected: AnyPublisher<Bool, Never> {
        selectedItemIndicesSubject
            .map { $0.contains(where: \.isInQueue) }
            .removeDuplicates()
            .eraseToAnyPublisher()
    }

    private let dependencies: Dependencies
    private let selectedItemIndicesSubject = CurrentValueSubject<[ItemIndex], Never>([])
    private let deselectAllItemsSubject = PassthroughSubject<Void, Never>()
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

        inputs.selectedItemIndices
            .subscribe(selectedItemIndicesSubject)
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
                .eraseToAnyPublisher(),
            deselectAllItems: deselectAllItemsSubject
                .eraseToAnyPublisher()
        )
    }
}

extension QueueListViewModel: QueueSelectionMenuViewModelDelegate {

    func selectionMenuRemoveButtonTapped() {
        let indices = selectedItemIndicesSubject.value .map(\.playbackQueueIndex)
        dependencies.playbackQueue.removeItems(at: indices)
    }

    func selectionMenuMoveToQueueButtonTapped() {
        deselectAllItemsSubject.send()
        let indices = selectedItemIndicesSubject.value .map(\.playbackQueueIndex)
        dependencies.playbackQueue.moveItemsToQueue(at: indices)
    }
}

// MARK: - Nested Types

extension QueueListViewModel {

    struct Dependencies {
        let playbackQueue: any PlaybackQueueType
    }

    struct Inputs {
        let movedItem: AnyPublisher<ItemMovement, Never>
        let selectedItemIndices: AnyPublisher<[ItemIndex], Never>
    }

    struct Outputs {
        let content: AnyPublisher<Content, Never>
        let sourceName: AnyPublisher<String?, Never>
        let deselectAllItems: AnyPublisher<Void, Never>
    }

    typealias ItemMovement = (from: ItemIndex, to: ItemIndex)

    enum ItemIndex {
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

        fileprivate var isInQueue: Bool {
            switch self {
            case .nextInQueue:
                return true
            default:
                return false
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
