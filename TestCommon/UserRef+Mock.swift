// Created by Alex Yaro on 2023-11-07.

@testable import Topsify
import Foundation

extension UserRef {
    static func mock(
        id: UUID = .init(),
        avatarURL: URL = .imageMockWithRandomID(),
        name: String = "John Doe"
    ) -> Self {
        .init(
            id: id,
            avatarURL: avatarURL,
            name: name
        )
    }
}
