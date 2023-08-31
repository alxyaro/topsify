// Created by Alex Yaro on 2023-04-09.

@testable import Topsify
import Foundation

extension Album {
    static func mock(
        id: UUID = .init(),
        artists: [User] = [.mock()],
        imageURL: URL = .imageMockWithRandomID(),
        title: String = "Test Album",
        type: AlbumType = .album,
        releaseDate: Date = .init(timeIntervalSince1970: 1692417172),
        accentColor: HexColor = .init("#0011ee")
    ) -> Self {
        .init(
            id: id,
            artists: artists,
            imageURL: imageURL,
            title: title,
            type: type,
            releaseDate: releaseDate,
            accentColor: accentColor
        )
    }
}
