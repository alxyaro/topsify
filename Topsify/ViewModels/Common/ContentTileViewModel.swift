// Created by Alex Yaro on 2022-05-02.

import Foundation

struct ContentTileViewModel: Equatable {
    let imageURL: URL
    let title: String?
    let subtitle: String
    let isCircular: Bool

    @IgnoreEquality private(set) var onTap: () -> Void
}
