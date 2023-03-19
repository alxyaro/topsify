//
//  SpotlightEntry.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-30.
//

import Foundation

enum SpotlightEntryModel {
    case generic(title: String, content: [ContentObject])
    case moreLike(user: User, content: [ContentObject])
}
