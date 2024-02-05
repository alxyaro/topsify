// Created by Alex Yaro on 2023-12-31.

import Foundation
import AVFoundation

struct PlaybackTiming {
    let duration: TimeInterval
    var elapsedDuration: TimeInterval
}

extension PlaybackTiming {

    init?(from playerItem: any PlayerItemType) {
        if playerItem.duration == .indefinite {
            return nil
        }
        duration = playerItem.duration.seconds
        elapsedDuration = playerItem.currentTime().seconds
    }
}
