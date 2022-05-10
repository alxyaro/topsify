//
//  HomeSpotlightMoreLikeViewModel.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-05-09.
//

import UIKit
import Combine

class HomeSpotlightMoreLikeViewModel {
    let user: User
    let contentObjects: [ContentObject]
    
    @LatePublished var userAvatar: UIImage?
    var userAvatarLoadCancellable: AnyCancellable?
    
    init(user: User, contentObjects: [ContentObject]) {
        self.user = user
        self.contentObjects = contentObjects
    }
    
    func loadUserAvatar() {
        if userAvatarLoadCancellable != nil || userAvatar != nil {
            return
        }
        userAvatarLoadCancellable = ImageService.fetchImage(id: user.avatarId, ofSize: .small).sink { [unowned self] _ in
            userAvatarLoadCancellable = nil
        } receiveValue: { [unowned self] image in
            self.userAvatar = image
        }
    }
}
