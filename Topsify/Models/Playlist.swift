// Created by Alex Yaro on 2022-04-17.

import Foundation

struct Playlist: Identifiable, Equatable {
    let id: UUID
    let creator: Creator
    let imageURL: URL
    let bannerImageURL: URL?
    let title: String
    let description: String?
    let isOfficial: Bool
    let isCoverSelfDescriptive: Bool
    let accentColor: HexColor
    let totalDuration: TimeInterval
}

extension Playlist {

    enum Creator: Equatable {
        case user(UserRef)
        case artist(ArtistRef)
    }
}

extension Playlist.Creator {

    var name: String {
        switch self {
        case .user(let userRef):
            return userRef.name
        case .artist(let artistRef):
            return artistRef.name
        }
    }

    var avatarURL: URL {
        switch self {
        case .user(let userRef):
            return userRef.avatarURL
        case .artist(let artistRef):
            return artistRef.avatarURL
        }
    }
}
