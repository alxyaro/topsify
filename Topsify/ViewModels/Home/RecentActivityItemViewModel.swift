// Created by Alex Yaro on 2023-02-19.

import Foundation

struct RecentActivityItemViewModel: Equatable {
    let title: String
    let imageURL: URL
}

extension RecentActivityItemViewModel {
    init(from content: ContentObject) {
        title = content.textValue
        imageURL = content.imageURL
    }
}
