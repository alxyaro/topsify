// Created by Alex Yaro on 2023-01-29.

import Foundation

struct Environment {
    let imageProvider: ImageProviderType
    let playbackQueue: any PlaybackQueueType
}

// MARK: - Current

extension Environment {
    static var current: Environment = .live()
}

// MARK: - Live

extension Environment {
    static func live() -> Environment {
        .init(
            imageProvider: ImageProvider(),
            playbackQueue: PlaybackQueue()
        )
    }
}
