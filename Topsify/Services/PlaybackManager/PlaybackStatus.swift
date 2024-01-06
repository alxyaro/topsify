// Created by Alex Yaro on 2023-12-31.

import Foundation

enum PlaybackStatus: Equatable {
    case notPlaying
    case playing
    case errored(PlaybackError)
}
