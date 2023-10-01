// Created by Alex Yaro on 2023-08-18.

import Combine
import Foundation

struct ArtworkBannerViewModel: Equatable {
    let accentColor: HexColor
    let artworkURL: URL
    let title: String
    let userInfo: [UserInfo]
    let details: String
    // let sideButtons: [SideButton]
}

// MARK: - Nested Types

extension ArtworkBannerViewModel {

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
