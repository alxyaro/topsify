// Created by Alex Yaro on 2023-07-11.

import Foundation

final class SongListCellViewModel {
    private let song: Song

    init(song: Song) {
        self.song = song
    }

    func outputs() -> Outputs {
        return Outputs(
            artworkURL: song.imageURL,
            title: song.title,
            subtitle: song.artists.map(\.name).commaJoined(),
            isExplicitLabelVisible: song.isExplicit
        )
    }
}

// MARK: - Nested Types

extension SongListCellViewModel {

    struct Outputs {
        let artworkURL: URL
        let title: String
        let subtitle: String
        let isExplicitLabelVisible: Bool
    }
}
