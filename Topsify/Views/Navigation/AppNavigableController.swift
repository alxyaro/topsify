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
    
	private var appNavigationController: AppNavigationController? {
		navigationController as? AppNavigationController
	}
    
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
}

extension AppNavigableController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        appNavigationController?.updateNavigationBarPosition()
    }
}
