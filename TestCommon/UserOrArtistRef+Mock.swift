// Created by Alex Yaro on 2023-12-26.

@testable import Topsify
import Foundation

extension UserOrArtistRef {

    static func mock(
        id: UUID = .init(),
        avatarURL: URL = .imageMockWithRandomID(),
        name: String = "First Last"
    ) -> Self {
        return .artist(.mock(id: id, avatarURL: avatarURL, name: name))
    }
}
