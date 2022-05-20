//
//  AppNavigationController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-10.
//

import UIKit

class AppNavigationController: UINavigationController {
    private static let navBarBottomSpacing: CGFloat = 8
    // storing this explicitly as there seems to be a bug with self.viewControllers during
    // popToRootViewController calls (the array becomes [top view controller, root view controller])
    // this breaks my animations, so storing root VC here explicitly
    // see this related post: https://developer.apple.com/forums/thread/702091
    let rootViewController: UIViewController
    let customNavBar = AppNavigationBar()
    var animationActive = false {
        didSet {
            // this is just for good measure
            // if UIVIewPropertyAnimator.isUserInteractionEnabled is not explicitly set to true,
            // the user can click on buttons in the nav bar before animation completes
            customNavBar.isUserInteractionEnabled = !animationActive
        }
    }
    let customPopGestureRecognizer = UIScreenEdgePanGestureRecognizer()
    var activePopGestureTransition: UIPercentDrivenInteractiveTransition?
    
    override init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        super.init(rootViewController: rootViewController)
        delegate = self
        customNavBar.navigationController = self
        
        navigationBar.isHidden = true
        isNavigationBarHidden = true
        
        view.addSubview(customNavBar)
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // force viewDidLoad to run
        _ = rootViewController.view
        customNavBar.update(for: rootViewController, isRoot: true)
        
        customPopGestureRecognizer.edges = .left
        customPopGestureRecognizer.addTarget(self, action: #selector(handlePopGesture))
        customPopGestureRecognizer.isEnabled = true
        customPopGestureRecognizer.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        customNavBar.updateFrame(using: topViewController!)
        
        topViewController!.additionalSafeAreaInsets.top = 0
        topViewController!.additionalSafeAreaInsets.top = customNavBar.bounds.height + Self.navBarBottomSpacing - view.safeAreaInsets.top
    }
    
    @objc private func handlePopGesture(sender: UIScreenEdgePanGestureRecognizer) {
        switch sender.state {
        case .began:
            if animationActive || activePopGestureTransition != nil || viewControllers.count < 2 {
                return;
            }
            activePopGestureTransition = UIPercentDrivenInteractiveTransition()
            popViewController(animated: true)
        case .changed:
            let pct = sender.translation(in: view).x / view.bounds.width
            activePopGestureTransition?.update(pct)
        case .ended, .cancelled:
            guard let activePopGestureTransition = activePopGestureTransition else {
                return
            }
            var shouldFinish = activePopGestureTransition.percentComplete > 0.5
            
            let velocity = sender.velocity(in: view).x
            if !shouldFinish && velocity > 100 {
                shouldFinish = true
            }
            
            if shouldFinish {
                activePopGestureTransition.finish()
            } else {
                activePopGestureTransition.cancel()
            }
            self.activePopGestureTransition = nil
        default:
            break
        }
    }
}

extension AppNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        interactivePopGestureRecognizer?.isEnabled = false
        if viewControllers.count > 1 {
            viewController.view.addGestureRecognizer(customPopGestureRecognizer)
        } else if let mountedView = customPopGestureRecognizer.view {
            mountedView.removeGestureRecognizer(customPopGestureRecognizer)
        }
        viewController.additionalSafeAreaInsets.top = customNavBar.bounds.height + Self.navBarBottomSpacing - view.safeAreaInsets.top
        // in case animated=false was used for the push/pop:
        customNavBar.update(for: viewController, isRoot: viewControllers.count == 1)
        customNavBar.currentViewController = viewController
    }
    
    func navigationController(_: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push, .pop:
            return NavigationTransitionController(operation: operation, navigationController: self)
        default: return nil
        }
    }
    
    func navigationController(_: UINavigationController, interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        activePopGestureTransition
    }
}

extension AppNavigationController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // any other gesture recognizer (otherGestureRecognizer) should require
        // failure of the custom pop recognizer to run
        return true
    }
}
