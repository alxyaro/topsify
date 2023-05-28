//
//  Album.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-29.
//

import Foundation

struct Album: Identifiable, Equatable {
    let id: UUID
    let artists: [User]
    let imageURL: URL
    let title: String
    let accentColorHex: String
}
