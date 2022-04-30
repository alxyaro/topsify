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
        switch contentObject {
        case .album(let album):
            return album.title
        case .song(let song):
            return song.title
        case .playlist(let playlist):
            return playlist.title
        case .user(let user):
            return user.name
        }
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
        
        let imageId: UUID
        switch contentObject {
        case .album(let album):
            imageId = album.imageId
        case .song(let song):
            imageId = song.imageId
        case .playlist(let playlist):
            imageId = playlist.imageId
        case .user(let user):
            imageId = user.avatarId
        }
        
        thumbnailLoadCancellable = ImageService.fetchImage(id: imageId).sink(receiveCompletion: { [unowned self] _ in
            thumbnailLoadCancellable = nil
        }, receiveValue: { [unowned self] thumbnail in
            self.thumbnail = thumbnail
        })
    }
}
