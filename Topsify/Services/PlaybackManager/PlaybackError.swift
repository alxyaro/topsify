// Created by Alex Yaro on 2023-12-31.

import Foundation

enum PlaybackError {
    case generic
}

extension PlaybackError: UserFacingError {
    var message: String {
        switch self {
        case .generic:
            NSLocalizedString("Something went wrong trying to play the song", comment: "Generic playback error message")
        }
    }
}
