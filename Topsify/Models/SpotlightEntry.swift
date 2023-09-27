// Created by Alex Yaro on 2022-04-30.

import Foundation

enum SpotlightEntry {
    case generic(Generic)
    case moreLike(MoreLike)
}

extension SpotlightEntry {

    struct Generic {
        let title: String
        let items: [ContentItem]
    }

    struct MoreLike {
        let artistInfo: ArtistInfo
        let items: [ContentItem]
    }

    struct ContentItem {
        let contentID: ContentID
        let imageURL: URL
        let title: String?
        let subtitle: String
    }

    struct ArtistInfo {
        let id: UUID
        let name: String
        let avatarURL: URL
    }
}
