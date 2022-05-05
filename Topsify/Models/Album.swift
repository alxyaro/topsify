//
//  Album.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-29.
//

import Foundation

struct Album: Identifiable, Codable {
    let id: UUID
    let artists: [User]
    let imageId: UUID
    let title: String
}
