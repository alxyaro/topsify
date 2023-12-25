// Created by Alex Yaro on 2023-12-10.

import Foundation

enum UserOrArtistRef: Equatable {
    case user(UserRef)
    case artist(ArtistRef)

    var contentID: ContentID {
        switch self {
        case .user(let userRef):
            return .init(contentType: .user, id: userRef.id)
        case .artist(let artistRef):
            return .init(contentType: .artist, id: artistRef.id)
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

    var name: String {
        switch self {
        case .user(let userRef):
            return userRef.name
        case .artist(let artistRef):
            return artistRef.name
        }
    }
}
