//
//  ContentObject.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-26.
//

import Foundation

enum ContentObject {
    case album(Album)
    case song(Song)
    case playlist(Playlist)
    case user(User)
}
