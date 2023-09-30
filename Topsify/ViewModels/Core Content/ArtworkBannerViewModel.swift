// Created by Alex Yaro on 2023-08-18.

import Combine
import Foundation

final class ArtworkBannerViewModel {
    private let dependencies: Dependencies

    private let accentColor: HexColor
    private let artworkURL: URL
    private let title: String
    private let userInfo: [UserInfo]
    private let details: String
    private let sideButtons: [SideButton]

    init(
        album: Album,
        dependencies: Dependencies
    ) {
        self.dependencies = dependencies

        accentColor = album.accentColor
        artworkURL = album.imageURL
        title = album.title
        userInfo = album.artists.map { UserInfo(avatarURL: $0.avatarURL, name: $0.name) }

        let releaseYear = dependencies.calendar.component(.year, from: album.releaseDate)
        details = [album.type.displayName, String(releaseYear)].bulletJoined()

        sideButtons = [.save, .download, .options]
    }

    func bind(inputs: Inputs) -> Outputs {
        return Outputs(
            accentColor: accentColor,
            artworkURL: artworkURL,
            title: title,
            userInfo: userInfo,
            details: details
            // sideButtons: sideButtons
        )
    }
}

// MARK: - Nested Types

extension ArtworkBannerViewModel {

    struct Dependencies {
        let calendar: Calendar
    }

    struct Inputs {
        // let tappedButton: AnyPublisher<SideButton, Never>
        // let tappedShuffleButton: AnyPublisher<Void, Never>
    }

    struct Outputs {
        let accentColor: HexColor
        let artworkURL: URL
        let title: String
        let userInfo: [UserInfo]
        let details: String
        // let sideButtons: [SideButton]
    }

    enum SideButton {
        case save
        case download
        case options
    }

    struct UserInfo: Equatable {
        let avatarURL: URL
        let name: String
    }
}
