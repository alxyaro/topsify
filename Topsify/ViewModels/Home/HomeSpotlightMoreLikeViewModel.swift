//
//  HomeSpotlightMoreLikeViewModel.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-05-09.
//

import UIKit
import Combine

struct HomeSpotlightMoreLikeViewModel {
    // FIXME: don't expose a model objects
    let contentObjects: [ContentObject]
    
    var userAvatarURL: URL {
        user.avatarURL
    }

    var userName: String {
        user.name
    }

    private let user: User
    
    init(user: User, contentObjects: [ContentObject]) {
        self.user = user
        self.contentObjects = contentObjects
    }
}
