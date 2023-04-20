// Created by Alex Yaro on 2023-04-20.

import Foundation

struct PlaybackQueueItem: Identifiable, Equatable {
    let id: UUID
    let song: Song
    let isUserQueueItem: Bool

    init(id: UUID = .init(), song: Song, isUserQueueItem: Bool = false) {
        self.id = id
        self.song = song
        self.isUserQueueItem = isUserQueueItem
    }
}
