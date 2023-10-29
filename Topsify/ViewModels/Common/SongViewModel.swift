// Created by Alex Yaro on 2023-07-11.

import Foundation

struct SongViewModel: Equatable {
    let artworkURL: URL
    let title: String
    let subtitle: String
    let showExplicitTag: Bool
    let optionsButtonVisibility: ButtonVisibility
}

extension SongViewModel {

    init(
        from song: Song,
        // TODO: remove default parameter and have callers properly specify it
        optionsButtonVisibility: ButtonVisibility = .shown(onTap: {})
    ) {
        artworkURL = song.imageURL
        title = song.title
        subtitle = song.artists.map(\.name).commaJoined()
        showExplicitTag = song.isExplicit
        self.optionsButtonVisibility = optionsButtonVisibility
    }
}
