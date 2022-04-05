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
        
        view.backgroundColor = UIColor(named: "Background")
        
        // TODO use a tab bar controller instead of this
        let child = HomeViewController()
        addChild(child)
        child.didMove(toParent: self)
        view.addSubview(child.view)
        
        child.view.translatesAutoresizingMaskIntoConstraints = true
        child.view.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }


}

