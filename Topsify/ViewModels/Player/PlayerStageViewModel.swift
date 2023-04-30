// Created by Alex Yaro on 2023-04-14.

import Foundation
import Combine

final class PlayerStageViewModel {

    private let playbackQueue: any PlaybackQueueType
    private var disposeBag = DisposeBag()

    init(playbackQueue: some PlaybackQueueType) {
        self.playbackQueue = playbackQueue
    }

    func bind(inputs: Inputs) -> Outputs {

        var lastItemList: ItemList?

        /// Change active item of `PlaybackQueue` when selected item index changes:
        inputs.stoppedOnItemAtIndex
            .compactMap { rawIndex, itemList in
                itemList.getPlaybackQueueIndex(for: rawIndex)
            }
            .sink { [playbackQueue] in
                playbackQueue.goToItem(atIndex: $0)
            }
            .store(in: &disposeBag)

        /// Nested function to unbox the `any PlaybackQueueType`:
        func itemListPublisher(using playbackQueue: some PlaybackQueueType) -> AnyPublisher<ItemList?, Never> {
            playbackQueue.stateWithContext
                .map { state, context -> ItemList? in

                    /// Ensure we have an active item. If not, the stage list should be empty.
                    guard state.activeItemIndex != nil else {
                        return nil
                    }

                    var itemList = ItemList(state: state)

                    switch context {
                    case .none:
                        break
                    case .movedToNextItem(let removedItem):
                        itemList.setTransitionData(transition: .movedForward, removedItem: removedItem, lastItemList: lastItemList)
                    case .movedToPreviousItem(let removedItem):
                        itemList.setTransitionData(transition: .movedBackward, removedItem: removedItem, lastItemList: lastItemList)
                    }

                    return itemList
                }
                .eraseToAnyPublisher()
        }

        let stoppedOnActiveItemIndex = inputs.stoppedOnItemAtIndex
            .filter { index, itemList in
                return index == itemList.activeItemIndex
            }
            .mapToVoid()

        let itemListClearedOfTransitionData = Publishers
            .Merge(
                inputs.willBeginDragging,
                stoppedOnActiveItemIndex
            )
            .compactMap { lastItemList }
            .filter { $0.hasTransitionData }
            .map { $0.withoutTransitionData }
            .mapOptional()

        let itemList = Publishers
            .Merge(
                itemListPublisher(using: playbackQueue),
                itemListClearedOfTransitionData
            )
            .map { itemList in
                lastItemList = itemList
                return itemList
            }

        return Outputs(
            itemList: itemList.eraseToAnyPublisher()
        )
    }
}

// MARK: - Nested Types

extension PlayerStageViewModel {

    struct Inputs {
        let stoppedOnItemAtIndex: AnyPublisher<(index: Int, itemList: ItemList), Never>
        let willBeginDragging: AnyPublisher<Void, Never>
    }

    struct Outputs {
        let itemList: AnyPublisher<ItemList?, Never>
    }

    struct Item: Equatable {
        let artworkURL: URL

        static func from(_ playbackQueueItem: PlaybackQueueItem) -> Self {
            .init(artworkURL: playbackQueueItem.song.imageURL)
        }
    }

    struct ItemList {

        enum Transition {
            case movedForward
            case movedBackward
        }

        var count: Int {
            state.count + placeholderItemsBeforeActiveItem.count + placeholderItemsAfterActiveItem.count
        }

        var activeItemIndex: Int {
            (state.activeItemIndex ?? 0) + placeholderItemsBeforeActiveItem.count
        }

        private(set) var transition: Transition?
        private var placeholderItemsBeforeActiveItem = [Item]()
        private var placeholderItemsAfterActiveItem = [Item]()

        private let state: any PlaybackQueueState

        subscript (itemAt index: Int) -> Item? {
            var index = index

            let placeholderItemsBeforeActiveItemStartIndex = activeItemIndex - placeholderItemsBeforeActiveItem.count
            if index >= placeholderItemsBeforeActiveItemStartIndex {
                if let extraItem = placeholderItemsBeforeActiveItem[safe: index - placeholderItemsBeforeActiveItemStartIndex] {
                    return extraItem
                }
                index -= placeholderItemsBeforeActiveItem.count
            }

            if index > activeItemIndex {
                if let extraItem = placeholderItemsAfterActiveItem[safe: index - (activeItemIndex + 1)] {
                    return extraItem
                }
                index -= placeholderItemsAfterActiveItem.count
            }

            guard let playbackQueueIndex = getPlaybackQueueIndex(for: index, using: state) else {
                return nil
            }

            return state[itemAt: playbackQueueIndex].map(Item.from)
        }

        private func getPlaybackQueueIndex(for rawIndex: Int, using state: some PlaybackQueueState) -> PlaybackQueueIndex? {
            .from(rawIndex: rawIndex, using: state)
        }
    }
}

private extension PlayerStageViewModel.ItemList {

    init(state: some PlaybackQueueState) {
        self.state = state
    }

    var hasTransitionData: Bool {
        transition != nil || !placeholderItemsBeforeActiveItem.isEmpty || !placeholderItemsAfterActiveItem.isEmpty
    }

    var withoutTransitionData: Self {
        var copy = self
        copy.transition = nil
        copy.placeholderItemsBeforeActiveItem = []
        copy.placeholderItemsAfterActiveItem = []
        return copy
    }

    mutating func setTransitionData(transition: Transition, removedItem: PlaybackQueueItem?, lastItemList: Self?) {
        self.transition = transition

        switch transition {
        case .movedForward:
            placeholderItemsAfterActiveItem = []
            if let removedItem {
                if let lastItemList {
                    placeholderItemsBeforeActiveItem += lastItemList.placeholderItemsBeforeActiveItem
                }
                placeholderItemsBeforeActiveItem.append(.from(removedItem))
            }
        case .movedBackward:
            placeholderItemsBeforeActiveItem = []
            if let removedItem {
                placeholderItemsAfterActiveItem.append(.from(removedItem))
                if let lastItemList {
                    placeholderItemsAfterActiveItem += lastItemList.placeholderItemsAfterActiveItem
                }
            }
        }
    }

    func getPlaybackQueueIndex(for index: Int) -> PlaybackQueueIndex? {
        var index = index

        let placeholderItemsBeforeActiveItemStartIndex = activeItemIndex - placeholderItemsBeforeActiveItem.count
        if index >= placeholderItemsBeforeActiveItemStartIndex {
            if placeholderItemsBeforeActiveItem[safe: index - placeholderItemsBeforeActiveItemStartIndex] != nil {
                return nil // index is for a fake/placeholder item; not a valid PlaybackQueue index
            }
            index -= placeholderItemsBeforeActiveItem.count
        }

        if index > activeItemIndex {
            if placeholderItemsAfterActiveItem[safe: index - activeItemIndex] != nil {
                return nil // index is for a fake/placeholder item; not a valid PlaybackQueue index
            }
            index -= placeholderItemsAfterActiveItem.count
        }

        return getPlaybackQueueIndex(for: index, using: state)
    }
}
