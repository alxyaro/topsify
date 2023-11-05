// Created by Alex Yaro on 2022-03-29.

import Foundation

struct Album: Identifiable, Equatable {
    let id: UUID
    let artists: [ArtistRef]
    let imageURL: URL
    let title: String
    let type: AlbumType
    let releaseDate: Date
    let accentColor: HexColor
}
