//
//  User.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-26.
//

import Foundation

struct User: Identifiable, Codable {
    let id: UUID
    let avatarId: UUID
    let name: String
    let isArtist: Bool
}
