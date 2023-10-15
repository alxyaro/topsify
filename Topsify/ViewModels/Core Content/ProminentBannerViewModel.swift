// Created by Alex Yaro on 2023-10-06.

import Foundation

struct ProminentBannerViewModel: Equatable {
    let accentColor: HexColor
    let backgroundImageURL: URL
    let title: String
    let details: Details
    let actionBarViewModel: BannerActionBarViewModel
}

extension ProminentBannerViewModel {

    enum Details: Equatable {
        case simple(String)
        case userAttributed(description: String?, attribution: [BannerUserAttribution], details: String)
    }

    struct UserInfo: Equatable {
        let avatarURL: URL
        let name: String
    }
}
