// Created by Alex Yaro on 2023-11-05.

import Foundation

struct Artist: Identifiable, Equatable {
    let id: UUID
    let avatarURL: URL
    let name: String
    let accentColor: HexColor
    let popularSongs: [PopularSong]
    let popularAlbums: [PopularAlbum]
    let about: About
    let recommendedArtists: [ArtistRef]
}

extension Artist {

    struct PopularSong: Equatable {
        let song: Song
        let totalPlays: Int
    }

    struct PopularAlbum: Equatable {
        let album: Album
        let isLatestRelease: Bool
    }

    struct About: Equatable {
        let photoURLs: [URL]
        let monthlyListeners: Int
        let worldRanking: Int?
        let descriptionMarkdown: String
    }
}
