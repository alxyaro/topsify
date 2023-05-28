// Created by Alex Yaro on 2023-04-07.

@testable import Topsify
import Foundation

extension Song {
    static func mock(
        id: UUID = .init(),
        artists: [User] = [.mock()],
        albumID: UUID? = .init(),
        imageURL: URL = .imageMockWithRandomID(),
        title: String = "Test Song",
        accentColorHex: String = "#0011ee"
    ) -> Self {
        .init(
            id: .init(),
            artists: artists,
            albumID: albumID,
            imageURL: imageURL,
            title: title,
            accentColorHex: accentColorHex
        )
    }
}

extension Array where Element == Song {

    static func mock(count: Int) -> [Song] {
        (1...count).map { Song.mock(title: "Song #\($0)") }
    }
}
