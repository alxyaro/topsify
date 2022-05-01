//
//  LibraryAPI.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-27.
//

import Foundation
import Combine

class LibraryAPI {
    
    func getSpotlight() -> AnyPublisher<[SpotlightEntry], Error> {
        return Future { promise in
            promise(.success([
                .contentList(title: "Jams to jump into", content: [
                    ContentObject.album(TestAlbums.catchTheseVibes),
                    ContentObject.song(TestSongs.turks),
                    ContentObject.album(TestAlbums.twoAlive),
                    ContentObject.album(TestAlbums.legendsNeverDie),
                    ContentObject.album(TestAlbums.soundcloudDaze),
                    ContentObject.album(TestAlbums.scorpion),
                ]),
                .contentList(title: "Made for Alex Yaro", content: [
                    ContentObject.playlist(TestPlaylists.dailyMix1),
                    ContentObject.playlist(TestPlaylists.dailyMix2),
                    ContentObject.playlist(TestPlaylists.dailyMix3),
                    ContentObject.playlist(TestPlaylists.dailyMix4),
                    ContentObject.playlist(TestPlaylists.dailyMix5),
                    ContentObject.playlist(TestPlaylists.releaseRadar),
                    ContentObject.playlist(TestPlaylists.timeCapsule),
                ]),
                .contentList(title: "Jump back in", content: [
                    ContentObject.album(TestAlbums.eternalAtake),
                    ContentObject.song(TestSongs.wantedYou),
                    ContentObject.song(TestSongs.loveMusic),
                    ContentObject.album(TestAlbums.plutoXBabyPluto),
                    ContentObject.album(TestAlbums.goodbyeAndGoodRiddance),
                    ContentObject.song(TestSongs.capToMe),
                    ContentObject.album(TestAlbums.perfectTiming),
                    ContentObject.album(TestAlbums.views),
                ]),
                .contentList(title: "Popular Hip-Hop playlists", content: [
                    ContentObject.playlist(TestPlaylists.rapCaviar),
                    ContentObject.playlist(TestPlaylists.hipHopFavourites),
                    ContentObject.playlist(TestPlaylists.newMusicFriday),
                    ContentObject.playlist(TestPlaylists.hitRewind),
                ]),
                .moreLike(user: TestUsers.nav, content: [
                    ContentObject.user(TestUsers.pnbRock),
                    ContentObject.album(TestAlbums.gttm),
                    ContentObject.song(TestSongs.wantedYou),
                    ContentObject.album(TestAlbums.soundcloudDaze),
                    ContentObject.album(TestAlbums.nav),
                    ContentObject.user(TestUsers.lilUziVert),
                    ContentObject.playlist(TestPlaylists.hipHopFavourites)
                ]),
                .contentList(title: "Uniquely yours", content: [
                    ContentObject.playlist(TestPlaylists.releaseRadar),
                    ContentObject.playlist(TestPlaylists.yourSummerRewind),
                    ContentObject.playlist(TestPlaylists.onRepeat),
                    ContentObject.playlist(TestPlaylists.timeCapsule),
                ]),
                .contentList(title: "Tear drops on the microphone", content: [
                    ContentObject.album(TestAlbums.legendsNeverDie),
                    ContentObject.album(TestAlbums.stoneyDeluxe),
                    ContentObject.album(TestAlbums.goodbyeAndGoodRiddance),
                    ContentObject.album(TestAlbums.catchTheseVibes),
                    ContentObject.album(TestAlbums.gttm),
                ]),
                .contentList(title: "Album picks", content: [
                    ContentObject.album(TestAlbums.soundcloudDaze),
                    ContentObject.album(TestAlbums.views),
                    ContentObject.album(TestAlbums.wunna),
                    ContentObject.album(TestAlbums.twoAlive),
                    ContentObject.album(TestAlbums.equals),
                ]),
                .contentList(title: "New releases for you", content: [
                    ContentObject.album(TestAlbums.twoAlive),
                    ContentObject.song(TestSongs.loveMusic),
                    ContentObject.song(TestSongs.capToMe),
                    ContentObject.album(TestAlbums.wunna),
                ]),
                .moreLike(user: TestUsers.lilUziVert, content: [
                    ContentObject.user(TestUsers.nav),
                    ContentObject.song(TestSongs.wantedYou),
                    ContentObject.user(TestUsers.future),
                    ContentObject.album(TestAlbums.twoAlive),
                    ContentObject.album(TestAlbums.perfectTiming),
                ]),
                .contentList(title: "Your playlists", content: [
                    ContentObject.playlist(TestPlaylists.vibey),
                    ContentObject.playlist(TestPlaylists.moody),
                    ContentObject.playlist(TestPlaylists.asmr),
                    ContentObject.playlist(TestPlaylists.goosebumpRap),
                ]),
                .contentList(title: "The ones that got away", content: [
                    ContentObject.album(TestAlbums.equals),
                    ContentObject.album(TestAlbums.scorpion),
                    ContentObject.album(TestAlbums.lilBoat2),
                    ContentObject.album(TestAlbums.views),
                ]),
            ]))
        }.eraseToAnyPublisher()
    }
}
