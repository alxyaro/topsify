// Created by Alex Yaro on 2022-04-26.

import Foundation

struct User: Identifiable, Equatable {
    let id: UUID
    let avatarURL: URL
    let name: String
    let isArtist: Bool
    let accentColor: HexColor
}
