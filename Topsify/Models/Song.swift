//
//  Song.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-29.
//

import Foundation

struct Song: Identifiable, Equatable {
    let id: UUID
    let artists: [User]
    let albumId: UUID?
    let imageURL: URL
    let title: String
}
