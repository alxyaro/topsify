//
//  SpotlightEntry.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-30.
//

import Foundation

// TODO: move into spotlight VM
// FIXME: do not expose ContentObject directly
enum SpotlightEntry {
    case contentList(title: String, content: [ContentObject])
    case moreLike(user: User, content: [ContentObject])
}
