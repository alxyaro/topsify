//
//  HomeViewModel.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-05-02.
//

import Foundation
import Combine

class HomeViewModel {
    @LatePublished var spotlight = [SpotlightEntry]()
    private var spotlightLoadCancellable: AnyCancellable?
    
    func load() {
        if spotlightLoadCancellable != nil {
            return
        }
        spotlightLoadCancellable = API.library.getSpotlight().sink { [unowned self] completion in
            spotlightLoadCancellable = nil
        } receiveValue: { [unowned self] spotlight in
            self.spotlight = spotlight
        }
    }
}
