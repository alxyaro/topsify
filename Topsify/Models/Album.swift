//
//  Album.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-29.
//

import Foundation

struct Album: Production, Codable {
    let imageId: String
    let title: String
    let artist: Artist
    let songs: [Song]
}
