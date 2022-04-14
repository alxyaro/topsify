//
//  AppNavigationController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-10.
//

import UIKit

class AppNavigationController: UINavigationController {
    let customNavBar = AppNavigationBar()
    var animationActive = false {
        didSet {
            // this is just for good measure
            // if UIVIewPropertyAnimator.isUserInteractionEnabled is not explicitly set to true,
            // the user can click on buttons in the nav bar before animation completes
            customNavBar.isUserInteractionEnabled = !animationActive
        }
    }
    let customPopGestureRecoginizer = UIScreenEdgePanGestureRecognizer()
    var activePopGestureTransition: UIPercentDrivenInteractiveTransition?
    
    override init(rootViewController: UIViewController) {
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
        
        customPopGestureRecoginizer.edges = .left
        customPopGestureRecoginizer.addTarget(self, action: #selector(handlePopGesture))
        customPopGestureRecoginizer.isEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topViewController?.additionalSafeAreaInsets.top = customNavBar.bounds.height - view.safeAreaInsets.top
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            viewController.view.addGestureRecognizer(customPopGestureRecoginizer)
        } else if let mountedView = customPopGestureRecoginizer.view {
            mountedView.removeGestureRecognizer(customPopGestureRecoginizer)
        }
        // in case animated=false was used for the push/pop:
        customNavBar.update(for: viewController, isRoot: viewControllers.count == 1)
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
