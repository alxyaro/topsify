//
//  Song.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-29.
//

import Foundation

struct Song: Identifiable, Equatable {
    let id: UUID
    let artists: [User]
    let albumID: UUID?
    let imageURL: URL
    let title: String
    let accentColorHex: String
}

extension Song {
    var isSingle: Bool {
        albumID == nil
    }
}

extension Song: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(title) (\(id.uuidString))"
    }
}
