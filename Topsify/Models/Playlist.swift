//
//  Playlist.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-17.
//

import Foundation

struct Playlist: Identifiable, Codable {
    let id: UUID
    let creator: User
    let imageId: UUID
    let title: String
    let description: String
    let isOfficial: Bool
    let isCoverSelfDescriptive: Bool
}
