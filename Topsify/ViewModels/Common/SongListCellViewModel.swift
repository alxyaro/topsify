// Created by Alex Yaro on 2023-07-11.

import Combine
import Foundation

final class SongListCellViewModel {
    private let song: Song
    private let showOptionsButton: Bool

    private(set) lazy var outputs = Outputs(
        artworkURL: song.imageURL,
        title: song.title,
        subtitle: song.artists.map(\.name).commaJoined(),
        showExplicitLabel: song.isExplicit,
        showOptionsButton: showOptionsButton
    )

    init(
        song: Song,
        showOptionsButton: Bool = true
    ) {
        self.song = song
        self.showOptionsButton = showOptionsButton
    }
}

// MARK: - Nested Types

extension SongListCellViewModel {

    struct Outputs {
        let artworkURL: URL
        let title: String
        let subtitle: String
        let showExplicitLabel: Bool
        let showOptionsButton: Bool
    }
}
