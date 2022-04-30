//
//  Song.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-29.
//

import Foundation

struct Song: Identifiable, Codable {
    let id: UUID
    let artistIds: [UUID]
    let imageId: UUID
    let title: String
}
