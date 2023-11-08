// Created by Alex Yaro on 2023-04-07.

@testable import Topsify
import Foundation

extension Song {
    static func mock(
        id: UUID = .init(),
        artists: [UserRef] = [.mock()],
        imageURL: URL = .imageMockWithRandomID(),
        title: String = "Test Song",
        accentColor: HexColor = .init("#0011ee"),
        isExplicit: Bool = false
    ) -> Self {
        .init(
            id: .init(),
            artists: artists,
            imageURL: imageURL,
            title: title,
            accentColor: accentColor,
            isExplicit: isExplicit
        )
    }
}

extension Array where Element == Song {

    static func mock(count: Int) -> [Song] {
        (1...count).map { Song.mock(title: "Song #\($0)") }
    }
}
