// Created by Alex Yaro on 2023-04-09.

@testable import Topsify
import Foundation

extension Playlist {
    static func mock(
        id: UUID = .init(),
        creator: User = .mock(),
        imageURL: URL = .imageMockWithRandomID(),
        title: String = "Test Playlist",
        description: String = "Just a test playlist",
        isOfficial: Bool = false,
        isCoverSelfDescriptive: Bool = false,
        accentColor: HexColor = .init("#0011ee"),
        totalDuration: TimeInterval = .minutes(42)
    ) -> Self {
        .init(
            id: id,
            creator: creator,
            imageURL: imageURL,
            title: title,
            description: description,
            isOfficial: isOfficial,
            isCoverSelfDescriptive: isCoverSelfDescriptive,
            accentColor: accentColor,
            totalDuration: totalDuration
        )
    }
}
