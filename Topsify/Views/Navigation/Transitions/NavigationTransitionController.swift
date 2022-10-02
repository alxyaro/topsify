//
//  NavigationTransitionController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-13.
//

import UIKit

class NavigationTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
    private let operation: UINavigationController.Operation
    private let navigationController: AppNavigationController
    private var animator: UIViewPropertyAnimator?
    
    init(operation: UINavigationController.Operation, navigationController: AppNavigationController) {
        self.operation = operation
        self.navigationController = navigationController

        // setting animationActive to true immediately as the call site is ran before
        // viewWillAppear on the appearing VC; viewWillAppear may set the title,
        // which would invoke AppNavigationController.updateNavigationBar, and
        // without this being set at that time, it would update the nav bar to the
        // final animation state before the animation even begins
        navigationController.animationActive = true
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
        navigationController.animationActive = true
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: .easeInOut)
        animator.isUserInteractionEnabled = false
        
        let pushing = operation == .push
        
        let fromView = transitionContext.view(forKey: .from)!
        let toView = transitionContext.view(forKey: .to)!
        
        let fadedView = pushing ? fromView : toView
        
        let fadeView = UIView()
        fadeView.backgroundColor = .black
        fadeView.alpha = pushing ? 0 : 0.5
        fadeView.bounds = fadedView.bounds
        fadeView.center = fadedView.center
        fadedView.addSubview(fadeView)
        
        if operation == .push {
            transitionContext.containerView.addSubview(toView)
        } else {
            transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
        }
        
        fromView.backgroundColor = .appBackground
        toView.backgroundColor = .appBackground
        
        if pushing {
            toView.frame = toView.frame.offsetBy(dx: toView.frame.width, dy: 0)
            animator.addAnimations {
                fromView.frame = fromView.frame.offsetBy(dx: -fromView.frame.width/3, dy: 0)
                toView.frame = toView.frame.offsetBy(dx: -toView.frame.width, dy: 0)
                fadeView.alpha = 0.5
            }
        } else {
            toView.frame = toView.frame.offsetBy(dx: -toView.frame.width/3, dy: 0)
            animator.addAnimations {
                toView.frame = toView.frame.offsetBy(dx: toView.frame.width/3, dy: 0)
                fromView.frame = fromView.frame.offsetBy(dx: fromView.frame.width, dy: 0)
                fadeView.alpha = 0
            }
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
            fadeView.removeFromSuperview()
            self.navigationController.animationActive = false
        }
        
        navigationController.customNavBar.transition(
            using: transitionContext,
            operation: operation,
            toRootVC: transitionContext.viewController(forKey: .to) === navigationController.rootViewController,
            animator: animator
        )
        
        self.animator = animator
        return animator
    }
}
