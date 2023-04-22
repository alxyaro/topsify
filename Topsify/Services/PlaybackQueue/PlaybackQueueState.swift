// Created by Alex Yaro on 2023-04-20.

import Foundation

protocol PlaybackQueueState {
    associatedtype HistoryCollection: Collection<PlaybackQueueItem> where HistoryCollection.Index == Int
    associatedtype UserQueueCollection: Collection<PlaybackQueueItem> where UserQueueCollection.Index == Int
    associatedtype UpNextCollection: Collection<PlaybackQueueItem> where UpNextCollection.Index == Int

    var history: HistoryCollection { get }
    var activeItem: PlaybackQueueItem? { get }
    var userQueue: UserQueueCollection { get }
    var upNext: UpNextCollection { get }

    var count: Int { get }
    var activeItemIndex: Int? { get }

    subscript (itemAt index: PlaybackQueueIndex) -> PlaybackQueueItem? { get }
}

extension PlaybackQueueState {
    var count: Int {
        history.count +
        (activeItem != nil ? 1 : 0) +
        userQueue.count +
        upNext.count
    }

    var activeItemIndex: Int? {
        activeItem != nil ? history.count : nil
    }

    subscript (itemAt index: PlaybackQueueIndex) -> PlaybackQueueItem? {
        switch index {
        case .history(let offset):
            return history[safe: offset]
        case .activeItem:
            return activeItem
        case .userQueue(let offset):
            return userQueue[safe: offset]
        case .upNext(let offset):
            return upNext[safe: offset]
        }
    }
}
