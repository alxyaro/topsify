// Created by Alex Yaro on 2023-02-19.

import Foundation

struct RecentActivityItemViewModel: Equatable {
    let title: String
    let imageURL: URL
    @IgnoreEquality var onTap: () -> Void
}
