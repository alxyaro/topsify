//
//  Production.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-29.
//

import Foundation

protocol Production: Codable {
    var imageId: String { get }
    var title: String { get }
    var artist: Artist { get }
}
