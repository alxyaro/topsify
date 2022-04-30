//
//  TestModelData.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-27.
//

import Foundation
import UIKit

class TestImages {
    static var namesToIds: Dictionary<String, UUID> = [:]
    static var idsToNames: Dictionary<UUID, String> = [:]
    
    static func getID(name: String) -> UUID {
        if let id = namesToIds[name] {
            return id
        }
        let id = UUID()
        namesToIds[name] = id
        idsToNames[id] = name
        return id
    }
}

class TestUsers {
    static let drake = User(id: UUID(), avatarId: TestImages.getID(name: "artist_drake"), name: "Drake", isArtist: true)
    static let edSheeran = User(id: UUID(), avatarId: TestImages.getID(name: "artist_ed-sheeran"), name: "Ed Sheeran", isArtist: true)
    static let future = User(id: UUID(), avatarId: TestImages.getID(name: "artist_future"), name: "Future", isArtist: true)
    static let gunna = User(id: UUID(), avatarId: TestImages.getID(name: "artist_gunna"), name: "Gunna", isArtist: true)
    static let juiceWrld = User(id: UUID(), avatarId: TestImages.getID(name: "artist_juice-wrld"), name: "Juice WRLD", isArtist: true)
    static let lilUziVert = User(id: UUID(), avatarId: TestImages.getID(name: "artist_lil-uzi-vert"), name: "Lil Uzi Vert", isArtist: true)
    static let lilYachty = User(id: UUID(), avatarId: TestImages.getID(name: "artist_lil-yachty"), name: "Lil Yachty", isArtist: true)
    static let nav = User(id: UUID(), avatarId: TestImages.getID(name: "artist_nav"), name: "NAV", isArtist: true)
    static let postMalone = User(id: UUID(), avatarId: TestImages.getID(name: "artist_post-malone"), name: "Post Malone", isArtist: true)
    static let yeat = User(id: UUID(), avatarId: TestImages.getID(name: "artist_yeat"), name: "Yeat", isArtist: true)
    
    static var all: [User] {
        Mirror(reflecting: Self.self).children.filter { child in
            child.value is User
        }.map { child in
            child.value as! User
        }
    }
}

class TestAlbums {
    static let twoAlive = Album(id: UUID(), artistIds: [TestUsers.yeat.id], imageId: TestImages.getID(name: "album_2-alive"), title: "2 Alive")
    static let equals = Album(id: UUID(), artistIds: [TestUsers.edSheeran.id], imageId: TestImages.getID(name: "album_equals"), title: "=")
    static let eternalAtake = Album(id: UUID(), artistIds: [TestUsers.lilUziVert.id], imageId: TestImages.getID(name: "album_eternal-atake"), title: "Eternal Atake")
    static let goodbyeAndGoodRiddance = Album(id: UUID(), artistIds: [TestUsers.juiceWrld.id], imageId: TestImages.getID(name: "album_goodbye-and-good-riddance"), title: "Goodbye & Good Riddance")
    static let perfectTiming = Album(id: UUID(), artistIds: [TestUsers.nav.id], imageId: TestImages.getID(name: "album_perfect-timing"), title: "Perfect Timing")
    static let plutoXBabyPluto = Album(id: UUID(), artistIds: [TestUsers.lilUziVert.id, TestUsers.future.id], imageId: TestImages.getID(name: "album_pluto-x-baby-pluto"), title: "Pluto x Baby Pluto")
    static let scorpion = Album(id: UUID(), artistIds: [TestUsers.drake.id], imageId: TestImages.getID(name: "album_scorpion"), title: "Scorpion")
    static let views = Album(id: UUID(), artistIds: [TestUsers.drake.id], imageId: TestImages.getID(name: "album_views"), title: "Views")
    static let wunna = Album(id: UUID(), artistIds: [TestUsers.gunna.id], imageId: TestImages.getID(name: "album_wunna"), title: "Wunna")
    
    static var all: [Album] {
        Mirror(reflecting: Self.self).children.filter { child in
            child.value is Album
        }.map { child in
            child.value as! Album
        }
    }
}


