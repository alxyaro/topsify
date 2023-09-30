// Created by Alex Yaro on 2023-08-18.

import Foundation

enum AlbumType {
    case single
    case ep
    case album

    var displayName: String {
        switch self {
        case .album:
            return NSLocalizedString("Album", comment: "Album type")
        case .single:
            return NSLocalizedString("Single", comment: "Album type")
        case .ep:
            return NSLocalizedString("EP", comment: "Album type")
        }
    }
}
