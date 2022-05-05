//
//  HomeRecentListeningActivityItemViewModel.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-16.
//

import UIKit
import Combine

class HomeRecentListeningActivityItemViewModel {
    private let contentObject: ContentObject
    var title: String {
        contentObject.textValue
    }
    @LatePublished private(set) var thumbnail: UIImage?
    private var thumbnailLoadCancellable: AnyCancellable?
    
    init(contentObject: ContentObject) {
        self.contentObject = contentObject
    }
    
    func loadThumbnail() {
        if thumbnailLoadCancellable != nil || thumbnail != nil {
            return
        }
        
        thumbnailLoadCancellable = ImageService.fetchImage(id: contentObject.imageId, ofSize: .small).sink(receiveCompletion: { [unowned self] _ in
            thumbnailLoadCancellable = nil
        }, receiveValue: { [unowned self] thumbnail in
            self.thumbnail = thumbnail
        })
    }
}
