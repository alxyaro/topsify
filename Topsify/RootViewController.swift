//
//  ViewController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-27.
//

import UIKit

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .appBackground
        
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
        
        let homeTabController = AppNavigationController(rootViewController: HomeViewController())
        homeTabController.title = "Home"
        homeTabController.tabBarItem.image = UIImage(systemName: "house", withConfiguration: symbolConfig)
        homeTabController.tabBarItem.selectedImage = UIImage(systemName: "house.fill", withConfiguration: symbolConfig)
        
        let temp1 = UIViewController()
        temp1.title = "Search"
        temp1.tabBarItem.image = UIImage(systemName: "magnifyingglass", withConfiguration: symbolConfig)
        temp1.tabBarItem.selectedImage = UIImage(systemName: "magnifyingglass", withConfiguration: symbolConfig)
        temp1.view.backgroundColor = .yellow
        
        let temp2 = UIViewController()
        temp2.title = "Library"
        temp2.tabBarItem.image = UIImage(systemName: "books.vertical", withConfiguration: symbolConfig)
        temp2.tabBarItem.selectedImage = UIImage(systemName: "books.vertical.fill", withConfiguration: symbolConfig)
        temp2.view.backgroundColor = .cyan
        
        let bottomAreaViewController = BottomAreaViewController(
            homeViewController: homeTabController,
            searchViewController: temp1,
            libraryViewController: temp2
        )
        
        addChild(bottomAreaViewController)
        view.addSubview(bottomAreaViewController.view)
        bottomAreaViewController.view.constrainEdgesToSuperview()
        bottomAreaViewController.didMove(toParent: self)
    }

}

