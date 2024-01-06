// Created by Alex Yaro on 2022-03-29.

import Foundation

struct Song: Identifiable, Equatable {
    let id: UUID
    let artists: [ArtistRef]
    let imageURL: URL
    let title: String
    let accentColor: HexColor
    let isExplicit: Bool
    let streamURL: URL
}

extension Song: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(title) (\(id.uuidString))"
    }
}
