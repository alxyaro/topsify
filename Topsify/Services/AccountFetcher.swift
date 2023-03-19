// Created by Alex Yaro on 2023-02-19.

import Foundation
import Combine

protocol AccountFetching {
    func recentActivity() -> Future<[ContentObject], Error>
}

// Simulating live implementation:
typealias AccountFetcher = FakeAccountFetcher

struct FakeAccountFetcher: AccountFetching {
    func recentActivity() -> Future<[ContentObject], Error> {
        .simulateLatency([
            .album(TestAlbums.eternalAtake),
            .album(TestAlbums.plutoXBabyPluto),
            .user(TestUsers.lilUziVert),
            .album(TestAlbums.goodbyeAndGoodRiddance),
            .user(TestUsers.nav),
            .album(TestAlbums.perfectTiming)
        ])
    }
}
