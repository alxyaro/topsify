//
//  ContentSquareViewModel.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-05-02.
//

import UIKit
import Combine

struct ContentTileViewModel {

    var imageURL: URL {
        content.imageURL
    }

    var title: String? {
        if case .playlist(let playlist) = content, playlist.isOfficial && playlist.isCoverSelfDescriptive {
            return nil
        }
        return content.textValue
    }
    
    var subtitle: String {
        if case .playlist(let playlist) = content {
            if playlist.isOfficial && playlist.isCoverSelfDescriptive {
                return playlist.description
            } else {
                return content.typeName+(playlist.description.count > 0 ? " \u{00B7} "+playlist.description : "")
            }
        }
        return content.typeName+" \u{00B7} "+content.attribution
    }
    
    var isCircular: Bool {
        switch content {
        case .user: return true
        default: return false
        }
    }

    private let content: ContentObject
    private let imageProvider: ImageProviderType
    
    init(
        content: ContentObject,
        imageProvider: ImageProviderType = Environment.current.imageProvider
    ) {
        self.content = content
        self.imageProvider = imageProvider
    }

    func prefetchImage() {
        imageProvider.prefetchImage(for: imageURL)
    }
}
