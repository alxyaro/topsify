//
//  HomeRecentArtifactViewModel.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-16.
//

import UIKit
import Combine

class HomeRecentArtifactViewModel: ObservableObject {
    @Published var title: String
    @Published var thumbnail: UIImage?
    
    init() {
        title = "Sample Content"
    }
    
    func loadThumbnail() {
        
    }
}
