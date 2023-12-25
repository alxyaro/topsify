// Created by Alex Yaro on 2023-10-06.

import Foundation

struct BannerActionBarViewModel: Equatable {
    let sideButtons: [SideButton]
    let shuffleButtonVisibility: ButtonVisibility
}

extension BannerActionBarViewModel {

    struct SideButton: Equatable {
        let buttonType: SideButtonType
        @IgnoreEquality private(set) var onTap: () -> Void
    }

    enum SideButtonType: Equatable {
        case save
        case download
        case options
        case follow(isFollowing: Bool)
    }
}
