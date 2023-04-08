// Created by Alex Yaro on 2023-04-07.

@testable import Topsify
import Foundation

extension Song {
    static func mock(
        id: UUID = .init(),
        artists: [User] = [.mock()],
        albumId: UUID? = .init(),
        imageURL: URL = .imageMock(),
        title: String = "Test Song"
    ) -> Self {
        .init(
            id: .init(),
            artists: artists,
            albumId: albumId,
            imageURL: imageURL,
            title: title
        )
    }
}
