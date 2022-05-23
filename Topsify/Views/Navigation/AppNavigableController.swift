//
//  AppNavigableController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-10.
//

import UIKit

class AppNavigableController: UIViewController {
    var isNavBarSticky = false
    var navBarButtons = [AppNavigationBarButton]()
    var mainScrollView: UIScrollView?
    
    private weak var appNavigationController: AppNavigationController?
    
    override var title: String? {
        didSet {
            guard oldValue != title else {
                return
            }
            appNavigationController?.updateNavigationBar()
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if mainScrollView == nil, let mainScrollView = view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
            self.mainScrollView = mainScrollView
            mainScrollView.delegate = self
        }
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        
        appNavigationController = navigationController as? AppNavigationController
    }
}

extension AppNavigableController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        appNavigationController?.childViewControllerDidScroll()
    }
}
