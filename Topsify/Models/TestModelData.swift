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
    static let pnbRock = User(id: UUID(), avatarId: TestImages.getID(name: "artist_pnb-rock"), name: "PnB Rock", isArtist: true)
    static let postMalone = User(id: UUID(), avatarId: TestImages.getID(name: "artist_post-malone"), name: "Post Malone", isArtist: true)
    static let yeat = User(id: UUID(), avatarId: TestImages.getID(name: "artist_yeat"), name: "Yeat", isArtist: true)
    
    static let topsify = User(id: UUID(), avatarId: TestImages.getID(name: "user_topsify"), name: "Topsify", isArtist: false)
    static let alexYaro = User(id: UUID(), avatarId: TestImages.getID(name: "user_alex-yaro"), name: "Alex Yaro", isArtist: false)
    
    static var all: [User] {
        Mirror(reflecting: Self.self).children.filter { child in
            child.value is User
        }.map { child in
            child.value as! User
        }
    }
}

class TestAlbums {
    static let twoAlive = Album(id: UUID(), artists: [TestUsers.yeat], imageId: TestImages.getID(name: "album_2-alive"), title: "2 Alive")
    static let catchTheseVibes = Album(id: UUID(), artists: [TestUsers.pnbRock], imageId: TestImages.getID(name: "album_catch-these-vibes"), title: "Catch These Vibes")
    static let equals = Album(id: UUID(), artists: [TestUsers.edSheeran], imageId: TestImages.getID(name: "album_equals"), title: "=")
    static let eternalAtake = Album(id: UUID(), artists: [TestUsers.lilUziVert], imageId: TestImages.getID(name: "album_eternal-atake"), title: "Eternal Atake")
    static let goodbyeAndGoodRiddance = Album(id: UUID(), artists: [TestUsers.juiceWrld], imageId: TestImages.getID(name: "album_goodbye-and-good-riddance"), title: "Goodbye & Good Riddance")
    static let gttm = Album(id: UUID(), artists: [TestUsers.pnbRock], imageId: TestImages.getID(name: "album_gttm"), title: "GTTM: Goin Thru the Motions")
    static let legendsNeverDie = Album(id: UUID(), artists: [TestUsers.juiceWrld], imageId: TestImages.getID(name: "album_legends-never-die"), title: "Legends Never Die")
    static let lilBoat2 = Album(id: UUID(), artists: [TestUsers.lilYachty], imageId: TestImages.getID(name: "album_lil-boat-2"), title: "Lil Boat 2")
    static let nav = Album(id: UUID(), artists: [TestUsers.nav], imageId: TestImages.getID(name: "album_nav"), title: "NAV")
    static let perfectTiming = Album(id: UUID(), artists: [TestUsers.nav], imageId: TestImages.getID(name: "album_perfect-timing"), title: "Perfect Timing")
    static let plutoXBabyPluto = Album(id: UUID(), artists: [TestUsers.lilUziVert, TestUsers.future], imageId: TestImages.getID(name: "album_pluto-x-baby-pluto"), title: "Pluto x Baby Pluto")
    static let scorpion = Album(id: UUID(), artists: [TestUsers.drake], imageId: TestImages.getID(name: "album_scorpion"), title: "Scorpion")
    static let soundcloudDaze = Album(id: UUID(), artists: [TestUsers.pnbRock], imageId: TestImages.getID(name: "album_soundcloud-daze"), title: "Soundcloud Daze")
    static let stoneyDeluxe = Album(id: UUID(), artists: [TestUsers.postMalone], imageId: TestImages.getID(name: "album_stoney-deluxe"), title: "Stoney (Deluxe)")
    static let views = Album(id: UUID(), artists: [TestUsers.drake], imageId: TestImages.getID(name: "album_views"), title: "Views")
    static let wunna = Album(id: UUID(), artists: [TestUsers.gunna], imageId: TestImages.getID(name: "album_wunna"), title: "Wunna")
    
    static var all: [Album] {
        Mirror(reflecting: Self.self).children.filter { child in
            child.value is Album
        }.map { child in
            child.value as! Album
        }
    }
}

class TestPlaylists {
    private static func create(title: String, desc: String, image: String, creator: User) -> Playlist {
        let isOfficial = creator.id == TestUsers.topsify.id
        return Playlist(id: UUID(), creator: creator, imageId: TestImages.getID(name: "playlist_"+image), title: title, description: desc, isOfficial: isOfficial, isCoverSelfDescriptive: isOfficial)
    }
    
    static let dailyMix1 = create(title: "Daily Mix 1", desc: "PnB Rock, Lil Uzi Vert, Yeat, and more", image: "daily-mix-1", creator: TestUsers.topsify)
    static let dailyMix2 = create(title: "Daily Mix 2", desc: "Future, Zach Farlow, Gunna, and more", image: "daily-mix-2", creator: TestUsers.topsify)
    static let dailyMix3 = create(title: "Daily Mix 3", desc: "Tobu, Coldplay, Hallman, and more", image: "daily-mix-3", creator: TestUsers.topsify)
    static let dailyMix4 = create(title: "Daily Mix 4", desc: "AK, Aurix, Rameses B, and more", image: "daily-mix-4", creator: TestUsers.topsify)
    static let dailyMix5 = create(title: "Daily Mix 5", desc: "Ava Max, Sam Smith, Khalid, and more", image: "daily-mix-5", creator: TestUsers.topsify)
    static let hipHopFavourites = create(title: "Hip-Hop Favourites", desc: "The songs you keep coming back to.", image: "hip-hop-favourites", creator: TestUsers.topsify)
    static let hitRewind = create(title: "Hit Rewind", desc: "All the tracks you've been missing.", image: "hit-rewind", creator: TestUsers.topsify)
    static let newMusicFriday = create(title: "New Music Friday", desc: "End the week with new favourites.", image: "new-music-friday", creator: TestUsers.topsify)
    static let onRepeat = create(title: "On Repeat", desc: "Songs you just can't stop listening to.", image: "on-repeat", creator: TestUsers.topsify)
    static let rapCaviar = create(title: "Rap Caviar", desc: "New music from Future, Lil Baby, and Lil Tjay.", image: "rap-caviar", creator: TestUsers.topsify)
    static let releaseRadar = create(title: "Release Radar", desc: "The latest music from artists you love.", image: "release-radar", creator: TestUsers.topsify)
    static let timeCapsule = create(title: "Time Capsule", desc: "A playlist to take you back in time.", image: "time-capsule", creator: TestUsers.topsify)
    static let yourSummerRewind = create(title: "Your Summer Rewind", desc: "Top tracks from the hottest days of summer.", image: "your-summer-rewind", creator: TestUsers.topsify)
    
    static let vibey = create(title: "Vibey", desc: "Vibes from all genres.", image: "sample1", creator: TestUsers.alexYaro)
    static let moody = create(title: "Moody", desc: "Tracks that make you think.", image: "sample2", creator: TestUsers.alexYaro)
    static let asmr = create(title: "ASMR", desc: "The ones that give you goosebumps.", image: "sample3", creator: TestUsers.alexYaro)
    static let goosebumpRap = create(title: "Goosebump Rap", desc: "", image: "sample4", creator: TestUsers.alexYaro)
    
    static var all: [Playlist] {
        Mirror(reflecting: Self.self).children.filter { child in
            child.value is Playlist
        }.map { child in
            child.value as! Playlist
        }
    }
}

class TestSongs {
    static let capToMe = Song(id: UUID(), artists: [TestUsers.yeat], albumId: nil, imageId: TestImages.getID(name: "single_cap-to-me"), title: "Cap to Me")
    static let loveMusic = Song(id: UUID(), artists: [TestUsers.lilYachty], albumId: nil, imageId: TestImages.getID(name: "single_love-music"), title: "Love Music")
    static let turks = Song(id: UUID(), artists: [TestUsers.nav, TestUsers.gunna], albumId: nil, imageId: TestImages.getID(name: "single_turks"), title: "Turks")
    static let wantedYou = Song(id: UUID(), artists: [TestUsers.nav, TestUsers.lilUziVert], albumId: nil, imageId: TestImages.getID(name: "single_wanted-you"), title: "Wanted You")
    
    static var all: [Song] {
        Mirror(reflecting: Self.self).children.filter { child in
            child.value is Song
        }.map { child in
            child.value as! Song
        }
    }
}
