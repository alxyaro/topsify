// Created by Alex Yaro on 2023-01-29.

import Foundation

struct Environment {
    let imageProvider: ImageProviderType
}

// MARK: - Current

extension Environment {
    static var current: Environment = .mock()
}

// MARK: - Live

extension Environment {
    /// For a live app, the following could be used:
    // static func live() -> Environment {}
}

// MARK: - Mock

extension Environment {
    static func mock() -> Environment {
        .init(
            imageProvider: MockImageProvider()
        )
    }
}
