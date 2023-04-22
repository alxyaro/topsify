// Created by Alex Yaro on 2023-04-14.

import Foundation
import Combine

final class PlayerStageViewModel {
    let itemList: AnyPublisher<ItemList?, Never>

    private let playbackQueue: any PlaybackQueueType

    init(playbackQueue: some PlaybackQueueType) {
        self.playbackQueue = playbackQueue

        self.itemList = playbackQueue.state
            .map { ItemList(state: $0) }
            .eraseToAnyPublisher()
    }

    func movedToItem(atIndex index: Int, itemList: ItemList) {
        if let index = itemList.getIndex(index) {
            playbackQueue.goToItem(atIndex: index)
        }
    }
}

// MARK: - Nested Types

extension PlayerStageViewModel {

    struct Item: Equatable {
        let artworkURL: URL
    }

    struct ItemList {
        let count: Int
        let activeItemIndex: Int
        fileprivate let getIndex: (Int) -> PlaybackQueueIndex?
        private let getItemAtClosure: (Int) -> Item?

        init?(state: some PlaybackQueueState) {
            guard let activeItemIndex = state.activeItemIndex else {
                return nil
            }
            count = state.count
            self.activeItemIndex = activeItemIndex
            getIndex = {
                PlaybackQueueIndex.from(rawIndex: $0, using: state)
            }
            getItemAtClosure = { [getIndex] in
                guard let index = getIndex($0) else { return nil }
                return state[itemAt: index].map { Item(artworkURL: $0.song.imageURL) }
            }
        }

        subscript (itemAt index: Int) -> Item? {
            getItemAtClosure(index)
        }
    }
}
