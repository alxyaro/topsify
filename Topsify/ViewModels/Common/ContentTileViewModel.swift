//
//  ContentSquareViewModel.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-05-02.
//

import UIKit
import Combine

struct ContentTileViewModel: Equatable {
    let imageURL: URL
    let title: String?
    let subtitle: String
    let isCircular: Bool

    @IgnoreEquality private(set) var onTap: () -> Void
}

extension ContentTileViewModel {
    init(
        from content: ContentObject,
        onTap: @escaping () -> Void = {}
    ) {
        imageURL = content.imageURL

        if case .playlist(let playlist) = content {
            if playlist.isOfficial && playlist.isCoverSelfDescriptive {
                title = nil
                subtitle = playlist.description
            } else {
                title = playlist.title
                subtitle = playlist.description.isEmpty ? content.typeName : [content.typeName, playlist.description].joinedBySpacedDot()
            }
        } else {
            title = content.textValue
            subtitle = [content.typeName, content.attribution].joinedBySpacedDot()
        }

        switch content {
        case .user:
            isCircular = true
        default:
            isCircular = false
        }

        self.onTap = onTap
    }
}
