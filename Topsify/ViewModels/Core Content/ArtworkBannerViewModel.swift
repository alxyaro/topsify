// Created by Alex Yaro on 2023-08-18.

import Foundation

struct ArtworkBannerViewModel: Equatable {
    let accentColor: HexColor
    let artworkURL: URL
    let title: String?
    let description: String?
    let userAttribution: [BannerUserAttribution]
    let details: String
    let actionBarViewModel: BannerActionBarViewModel
}

extension ArtworkBannerViewModel {

    struct UserInfo: Equatable {
        let avatarURL: URL
        let name: String
    }
}
