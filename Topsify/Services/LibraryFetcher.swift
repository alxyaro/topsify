// Created by Alex Yaro on 2023-02-05.

import Foundation
import Combine

protocol LibraryFetching {
    func spotlightEntries() -> Future<[SpotlightEntryModel], Error>
}

// Simulating live implementation:
typealias LibraryFetcher = FakeLibraryFetcher

struct FakeLibraryFetcher: LibraryFetching {
    func spotlightEntries() -> Future<[SpotlightEntryModel], Error> {
        .simulateLatency([
            .generic(title: "Jams to jump into", content: [
                ContentObject.album(TestAlbums.catchTheseVibes),
                ContentObject.song(TestSongs.turks),
                ContentObject.album(TestAlbums.twoAlive),
                ContentObject.album(TestAlbums.legendsNeverDie),
                ContentObject.album(TestAlbums.soundcloudDaze),
                ContentObject.album(TestAlbums.scorpion),
            ]),
            .generic(title: "Made for Alex Yaro", content: [
                ContentObject.playlist(TestPlaylists.dailyMix1),
                ContentObject.playlist(TestPlaylists.dailyMix2),
                ContentObject.playlist(TestPlaylists.dailyMix3),
                ContentObject.playlist(TestPlaylists.dailyMix4),
                ContentObject.playlist(TestPlaylists.dailyMix5),
                ContentObject.playlist(TestPlaylists.releaseRadar),
                ContentObject.playlist(TestPlaylists.timeCapsule),
            ]),
            .generic(title: "Jump back in", content: [
                ContentObject.album(TestAlbums.eternalAtake),
                ContentObject.song(TestSongs.wantedYou),
                ContentObject.song(TestSongs.loveMusic),
                ContentObject.album(TestAlbums.plutoXBabyPluto),
                ContentObject.album(TestAlbums.goodbyeAndGoodRiddance),
                ContentObject.song(TestSongs.capToMe),
                ContentObject.album(TestAlbums.perfectTiming),
                ContentObject.album(TestAlbums.views),
            ]),
            .generic(title: "Popular Hip-Hop playlists", content: [
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
            .generic(title: "Uniquely yours", content: [
                ContentObject.playlist(TestPlaylists.releaseRadar),
                ContentObject.playlist(TestPlaylists.yourSummerRewind),
                ContentObject.playlist(TestPlaylists.onRepeat),
                ContentObject.playlist(TestPlaylists.timeCapsule),
            ]),
            .generic(title: "Tear drops on the microphone", content: [
                ContentObject.album(TestAlbums.legendsNeverDie),
                ContentObject.album(TestAlbums.stoneyDeluxe),
                ContentObject.album(TestAlbums.goodbyeAndGoodRiddance),
                ContentObject.album(TestAlbums.catchTheseVibes),
                ContentObject.album(TestAlbums.gttm),
            ]),
            .generic(title: "Album picks", content: [
                ContentObject.album(TestAlbums.soundcloudDaze),
                ContentObject.album(TestAlbums.views),
                ContentObject.album(TestAlbums.wunna),
                ContentObject.album(TestAlbums.twoAlive),
                ContentObject.album(TestAlbums.equals),
            ]),
            .generic(title: "New releases for you", content: [
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
            .generic(title: "Your playlists", content: [
                ContentObject.playlist(TestPlaylists.vibey),
                ContentObject.playlist(TestPlaylists.moody),
                ContentObject.playlist(TestPlaylists.asmr),
                ContentObject.playlist(TestPlaylists.goosebumpRap),
            ]),
            .generic(title: "The ones that got away", content: [
                ContentObject.album(TestAlbums.equals),
                ContentObject.album(TestAlbums.scorpion),
                ContentObject.album(TestAlbums.lilBoat2),
                ContentObject.album(TestAlbums.views),
            ])
        ])
    }
}
