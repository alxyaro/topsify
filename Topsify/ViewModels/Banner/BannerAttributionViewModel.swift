// Created by Alex Yaro on 2023-12-10.

import Foundation

struct BannerAttributionViewModel: Equatable {
    let attribution: [UserOrArtistRef]
    @IgnoreEquality var onTap: (UserOrArtistRef) -> Void
}
