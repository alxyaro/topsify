// Created by Alex Yaro on 2023-04-09.

@testable import Topsify
import Foundation

extension Album {
    static func mock(
        id: UUID = .init(),
        artists: [User] = [.mock()],
        imageURL: URL = .imageMock(token: "album_cover"),
        title: String = "Test Album"
    ) -> Self {
        .init(
            id: id,
            artists: artists,
            imageURL: imageURL,
            title: title
        )
    }
}
