// Created by Alex Yaro on 2023-04-07.

@testable import Topsify
import Foundation

extension User {
    static func mock(
        id: UUID = .init(),
        avatarURL: URL = .imageMock(),
        name: String = "Alex Yaro",
        isArtist: Bool = false
    ) -> Self {
        .init(
            id: id,
            avatarURL: avatarURL,
            name: name,
            isArtist: isArtist
        )
    }
}
