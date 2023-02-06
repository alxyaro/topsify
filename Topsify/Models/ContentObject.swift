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
    
    var typeName: String {
        switch self {
        case .album:
            return "Album"
        case .song(let song):
            return song.albumId != nil ? "Track" : "Single"
        case .playlist:
            return "Playlist"
        case .user(let user):
            return user.isArtist ? "Artist" : "User"
        }
    }
    
    var id: UUID {
        switch self {
        case .album(let album):
            return album.id
        case .song(let song):
            return song.id
        case .playlist(let playlist):
            return playlist.id
        case .user(let user):
            return user.id
        }
    }
    
    var imageURL: URL {
        switch self {
        case .album(let album):
            return album.imageURL
        case .song(let song):
            return song.imageURL
        case .playlist(let playlist):
            return playlist.imageURL
        case .user(let user):
            return user.avatarURL
        }
    }
    
    var textValue: String {
        switch self {
        case .album(let album):
            return album.title
        case .song(let song):
            return song.title
        case .playlist(let playlist):
            return playlist.title
        case .user(let user):
            return user.name
        }
    }
    
    var attribution: String {
        switch self {
        case .album(let album):
            return album.artists.map(\.name).joined(separator: ", ")
        case .song(let song):
            return song.artists.map(\.name).joined(separator: ", ")
        case .playlist(let playlist):
            return playlist.creator.name
        case .user(let user):
            return user.name
        }
    }
}
