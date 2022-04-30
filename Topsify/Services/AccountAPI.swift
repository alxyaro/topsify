//
//  AccountAPI.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-27.
//

import Foundation
import Combine

class AccountAPI {
    func getRecentListeningActivity() -> AnyPublisher<[ContentObject], Error> {
        return Future<[ContentObject], Error> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0..<1)) {
                promise(.success([
                    .album(TestAlbums.eternalAtake),
                    .album(TestAlbums.plutoXBabyPluto),
                    .user(TestUsers.lilUziVert),
                    .album(TestAlbums.goodbyeAndGoodRiddance),
                    .user(TestUsers.nav),
                    .album(TestAlbums.perfectTiming),
                ]))
            }
        }.eraseToAnyPublisher()
    }
}
