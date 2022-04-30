//
//  HomeRecentListeningActivityViewModel.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-30.
//

import Foundation
import Combine

class HomeRecentListeningActivityViewModel {
    @LatePublished private(set) var recentActivity = [ContentObject]()
    private var recentActivityLoadCancellable: AnyCancellable?
    
    func loadData() {
        if recentActivityLoadCancellable != nil {
            return
        }
        recentActivityLoadCancellable = API.account.getRecentListeningActivity().sink(receiveCompletion: { [unowned self] _ in
            recentActivityLoadCancellable = nil
        }, receiveValue: { [unowned self] recentActivity in
            self.recentActivity = recentActivity
        })
    }
}
