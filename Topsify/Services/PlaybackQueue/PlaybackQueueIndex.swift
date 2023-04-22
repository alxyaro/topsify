// Created by Alex Yaro on 2023-04-22.

import Foundation

enum PlaybackQueueIndex: Equatable {
    case history(Int)
    case activeItem
    case userQueue(Int)
    case upNext(Int)
}

extension PlaybackQueueIndex {
    static func from(rawIndex: Int, using state: some PlaybackQueueState) -> Self? {
        var rawIndex = rawIndex
        if rawIndex < 0 {
            return nil
        }
        if rawIndex < state.history.count {
            return .history(rawIndex)
        }
        rawIndex -= state.history.count
        if state.activeItem != nil {
            if rawIndex == 0 {
                return .activeItem
            }
            rawIndex -= 1
        }
        if rawIndex < state.userQueue.count {
            return .userQueue(rawIndex)
        }
        rawIndex -= state.userQueue.count
        if rawIndex < state.upNext.count {
            return .upNext(rawIndex)
        }
        return nil
    }

    func isValid(for state: some PlaybackQueueState) -> Bool {
        switch self {
        case .history(let offset):
            return (0..<state.history.count).contains(offset)
        case .activeItem:
            return state.activeItem != nil
        case .userQueue(let offset):
            return (0..<state.userQueue.count).contains(offset)
        case .upNext(let offset):
            return (0..<state.upNext.count).contains(offset)
        }
    }
}
