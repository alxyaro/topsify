// Created by Alex Yaro on 2023-03-01.

import Foundation

struct HomeArtistHeaderCellViewModel: Equatable {
    let imageURL: URL
    let artistName: String
    let captionText: String
}

extension HomeArtistHeaderCellViewModel {
    init(from user: User, captionText: String) {
        imageURL = user.avatarURL
        artistName = user.name
        self.captionText = captionText
    }
}
