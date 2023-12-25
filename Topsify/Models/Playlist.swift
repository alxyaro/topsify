// Created by Alex Yaro on 2022-04-17.

import Foundation

struct Playlist: Identifiable, Equatable {
    let id: UUID
    let creator: UserOrArtistRef
    let imageURL: URL
    let bannerImageURL: URL?
    let title: String
    let description: String?
    let isOfficial: Bool
    let isCoverSelfDescriptive: Bool
    let accentColor: HexColor
    let totalDuration: TimeInterval
}
