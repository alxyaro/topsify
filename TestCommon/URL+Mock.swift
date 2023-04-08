// Created by Alex Yaro on 2023-04-07.

import Foundation

extension URL {
    static func imageMock(
        token: String = "abc123"
    ) -> Self {
        .init(string: "https://yaro.dev/topsify/mock-images/\(token).png")!
    }
}
