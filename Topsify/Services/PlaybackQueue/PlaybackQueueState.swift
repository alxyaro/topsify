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
    var activeItemIndex: Int { get }

    subscript (itemAt index: Int) -> PlaybackQueueItem? { get }
}

extension PlaybackQueueState {
    var count: Int {
        history.count +
        (activeItem != nil ? 1 : 0) +
        userQueue.count +
        upNext.count
    }

    var activeItemIndex: Int {
        activeItem != nil ? history.count : -1
    }

    subscript (itemAt index: Int) -> PlaybackQueueItem? {
        var index = index
        if index < history.count {
            return history[safe: index]
        }
        index -= history.count
        if index == 0 {
            return activeItem
        }
        index -= 1
        if index < userQueue.count {
            return userQueue[safe: index]
        }
        index -= userQueue.count
        return upNext[safe: index]
    }
}
