// Created by Alex Yaro on 2023-04-07.

@testable import Topsify
import Foundation

extension User {
    static func mock(
        id: UUID = .init(),
        avatarURL: URL = .imageMockWithRandomID(),
        name: String = "Alex Yaro",
        isArtist: Bool = false,
        accentColor: HexColor = .init("#0011ee")
    ) -> Self {
        .init(
            id: id,
            avatarURL: avatarURL,
            name: name,
            isArtist: isArtist,
            accentColor: accentColor
        )
    }
}
