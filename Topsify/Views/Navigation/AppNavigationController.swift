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
            /// Prevent the user from tapping the buttons during animation.
            /// This is technically not required here, but kept for good measure, as the `NavigationTransitionCoordinator`
            /// sets it's `UIViewPropertyAnimator`'s `isUserInteractionEnabled` property to `false`, which
            /// should prevent interaction with the nav bar buttons on its own.
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
        customNavBar.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
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
        updateTopViewControllerSafeArea()
        // important check - repositioning during navbar animation will likely make it glitch
        if !animationActive {
            customNavBar.updatePosition(using: topViewController!)
        }
    }
    
    private func updateTopViewControllerSafeArea() {
        topViewController?.additionalSafeAreaInsets.top = customNavBar.getMaximumHeight() + Self.navBarBottomSpacing - view.safeAreaInsets.top
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
    
    func updateNavigationBarPosition() {
        if animationActive {
            return
        }
        customNavBar.updatePosition(using: topViewController!)
    }
    
    func updateNavigationBar() {
        if animationActive {
            return
        }
        customNavBar.update(for: topViewController!, isRoot: topViewController === rootViewController)
    }
}

extension AppNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        // note: this will also be called when showing initial view controller
        interactivePopGestureRecognizer?.isEnabled = false
        if viewControllers.count > 1 {
            viewController.view.addGestureRecognizer(customPopGestureRecognizer)
        } else if let mountedView = customPopGestureRecognizer.view {
            mountedView.removeGestureRecognizer(customPopGestureRecognizer)
        }
        updateTopViewControllerSafeArea()
        // TODO: on interactive animations, animationActive is still true when this is called, so it doesn't do much
        // see if this needs to be addressed
        updateNavigationBar()
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
