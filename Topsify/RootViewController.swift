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
        
        let homeTabController = NewAppNavigationController(rootViewController: HomeViewController())
        homeTabController.title = "Home"
        
        let temp1 = UIViewController()
        temp1.title = "Search"
        temp1.view.backgroundColor = .yellow
        
        let temp2 = UIViewController()
        temp2.title = "Library"
        temp2.view.backgroundColor = .cyan
        
        let bottomAreaViewController = BottomAreaViewController(
            homeViewController: homeTabController,
            searchViewController: temp1,
            libraryViewController: temp2,
            playBarViewModel: .init(dependencies: .live())
        )
        
        addChild(bottomAreaViewController)
        view.addSubview(bottomAreaViewController.view)
        bottomAreaViewController.view.constrainEdgesToSuperview()
        bottomAreaViewController.didMove(toParent: self)
    }

}

