//
//  AppTabBarController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-05-12.
//

import UIKit

class AppTabBarController: UITabBarController {
    let customTabBar: AppTabBar
    
    override var selectedViewController: UIViewController? {
        didSet {
            if let selectedViewController = selectedViewController {
                customTabBar.buttons.forEach { button in
                    button.isSelected = button.viewController === selectedViewController
                }
            }
        }
    }
    
    init(viewControllers: [UIViewController]) {
        customTabBar = AppTabBar(buttons: viewControllers.map {
            AppTabBarButton(viewController: $0)
        })
        
        super.init(nibName: nil, bundle: nil)
        self.viewControllers = viewControllers
        delegate = self
        
        customTabBar.buttons.forEach { button in
            button.onTap = { [unowned self] in
                if let vc = button.viewController {
                    if selectedViewController === vc, let navigationVC = vc as? UINavigationController {
                        // tab already selected
                        if navigationVC.topViewController === navigationVC.viewControllers[0] {
                            // root controller visible, scroll to top
                            let scrollView = navigationVC.viewControllers[0].view.subviews.first { $0 is UIScrollView } as! UIScrollView
                            scrollView.scrollRectToVisible(CGRect(origin: .zero, size: CGSize(width: 1, height: 1)), animated: true)
                        } else {
                            // pop to root vc
                            navigationVC.popToRootViewController(animated: true)
                        }
                    }
                    selectedViewController = vc
                }
            }
        }
        
        // explicitly run didSet property observer
        selectedViewController = selectedViewController
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.isHidden = true
        view.addSubview(customTabBar)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        additionalSafeAreaInsets.bottom = 0
        
        var appBarHeight = AppTabBar.height + view.safeAreaInsets.bottom
        if view.safeAreaInsets.bottom > 0 {
            // if there's space, sink the tab bar into the safe area by a maximum of 10 points
            appBarHeight -= min(view.safeAreaInsets.bottom, 10)
        }
        
        customTabBar.frame = CGRect(
            x: 0,
            y: view.frame.height - appBarHeight,
            width: view.frame.width,
            height: appBarHeight
        )
        
        additionalSafeAreaInsets.bottom = AppTabBar.height
    }
}

extension AppTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TabTransitionController()
    }
}
