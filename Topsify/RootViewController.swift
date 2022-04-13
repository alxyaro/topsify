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
        
        let tempNavController = AppNavigationController(rootViewController: HomeViewController())
        
        // TODO use a tab bar controller instead of this
        addChild(tempNavController)
        tempNavController.didMove(toParent: self)
        view.addSubview(tempNavController.view)
        
        tempNavController.view.constrain(into: view)
    }


}

