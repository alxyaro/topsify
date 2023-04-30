// Created by Alex Yaro on 2023-04-07.

import Foundation

extension URL {
    static func imageMock(
        id: String = "abc123"
    ) -> Self {
        .init(string: "https://yaro.dev/topsify/mock-images/\(id).png")!
    }

    static func imageMockWithRandomID() -> Self {
        imageMock(id: UUID().uuidString)
    }
}
