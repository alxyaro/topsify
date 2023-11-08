// Created by Alex Yaro on 2023-04-09.

@testable import Topsify
import Foundation

extension Playlist {
    static func mock(
        id: UUID = .init(),
        creator: Creator = .mock(),
        imageURL: URL = .imageMockWithRandomID(),
        bannerImageURL: URL? = nil,
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
            bannerImageURL: bannerImageURL,
            title: title,
            description: description,
            isOfficial: isOfficial,
            isCoverSelfDescriptive: isCoverSelfDescriptive,
            accentColor: accentColor,
            totalDuration: totalDuration
        )
    }
}

extension Playlist.Creator {

    static func mock(
        id: ContentID = .mock(contentType: .artist),
        avatarURL: URL = .imageMockWithRandomID(),
        name: String = "Creator Name"
    ) -> Self {
        switch id.contentType {
        case .artist:
            return .artist(.mock(id: id.id, avatarURL: avatarURL, name: name))
        case .user:
            return .user(.mock(id: id.id, avatarURL: avatarURL, name: name))
        default:
            fatalError("Unexpected ContentID given to \(Self.self).\(#function)")
        }
    }
}
