//
//  Song.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-29.
//

import Foundation

struct Song: Production, Codable {
    let imageId: String
    let title: String
    let artist: Artist
}
