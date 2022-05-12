//
//  ContentSquareViewModel.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-05-02.
//

import UIKit
import Combine

class ContentSquareViewModel {
    private var content: ContentObject
    @LatePublished var image: UIImage?
    private var imageLoadCancellable: AnyCancellable?
    
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
    
    var circular: Bool {
        if case .user = content {
            return true
        }
        return false
    }
    
    init(content: ContentObject) {
        self.content = content
    }
    
    func loadImage() {
        if imageLoadCancellable != nil || image != nil {
            return
        }
        imageLoadCancellable = ImageService.fetchImage(id: content.imageId, ofSize: .medium).sink(receiveCompletion: { [unowned self] _ in
            imageLoadCancellable = nil
        }, receiveValue: { [unowned self] image in
            self.image = image
        })
    }
}
