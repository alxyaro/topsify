//
//  AppNavigationController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-10.
//

import UIKit

class AppNavigationController: UINavigationController {
    let rootViewController: UIViewController
    let customNavBar = AppNavigationBar()
    var initialSetupComplete = false
    
    override init(rootViewController: UIViewController) {
        self.rootViewController = rootViewController
        
        super.init(rootViewController: rootViewController)
        delegate = self
        
        navigationBar.isHidden = true
        isNavigationBarHidden = true
        
        view.addSubview(customNavBar)
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        // force viewDidLoad to run
        _ = rootViewController.view
        customNavBar.update(for: rootViewController, isRoot: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        topViewController?.additionalSafeAreaInsets.top = customNavBar.bounds.height - view.safeAreaInsets.top
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AppNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        
    }
    
    func navigationController(_: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        switch operation {
        case .push:
            return NavigationPushTransition(navigationController: self)
        default: return nil
        }
    }
}

fileprivate class NavigationPushTransition: NSObject, UIViewControllerAnimatedTransitioning {
    private let navigationController: AppNavigationController
    private var animator: UIViewPropertyAnimator?
    
    init(navigationController: AppNavigationController) {
        self.navigationController = navigationController
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        animator.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let animator = animator {
            return animator
        }
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: .easeInOut)
        
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        let tempOverlay = UIView()
        tempOverlay.backgroundColor = .black
        tempOverlay.alpha = 0
        tempOverlay.bounds = fromView.bounds
        tempOverlay.center = fromView.center
        fromView.addSubview(tempOverlay)
        
        transitionContext.containerView.addSubview(toView)
        toView.backgroundColor = .appBackground
        
        toView.frame = toView.frame.offsetBy(dx: toView.frame.width, dy: 0)
        animator.addAnimations {
            fromView.frame = fromView.frame.offsetBy(dx: -fromView.frame.width/3, dy: 0)
            toView.frame = toView.frame.offsetBy(dx: -toView.frame.width, dy: 0)
            tempOverlay.alpha = 0.5
        }
        
        animator.addCompletion { pos in
            let completed = pos == .end
            transitionContext.completeTransition(completed)
            if completed {
                transitionContext.finishInteractiveTransition()
                fromView.removeFromSuperview()
            } else {
                transitionContext.cancelInteractiveTransition()
                toView.removeFromSuperview()
            }
            tempOverlay.removeFromSuperview()
        }
        
        navigationController.customNavBar.pushTransition(using: (
            fromVC: transitionContext.viewController(forKey: .from)!,
            toVC: transitionContext.viewController(forKey: .to)!,
            containerView: transitionContext.containerView
        ), animator: animator)
        
        self.animator = animator
        return animator
    }
}
