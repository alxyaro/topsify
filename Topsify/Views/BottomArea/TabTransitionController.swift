//
//  TabTransitionController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-05-20.
//

import Foundation
import UIKit

/// Animation controller for switching between app tabs, using a crossfade effect.
class TabTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
    private var animator: UIViewPropertyAnimator?
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.15
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
        
        let toView = transitionContext.view(forKey: .to)!
        let fromView = transitionContext.view(forKey: .from)!
        
        toView.alpha = 0
        transitionContext.containerView.addSubview(toView)
        
        animator.addAnimations {
            fromView.alpha = 0
            toView.alpha = 1
        }
        
        animator.addCompletion { pos in
            transitionContext.completeTransition(pos == .end)
            if pos == .end {
                fromView.removeFromSuperview()
            } else {
                toView.removeFromSuperview()
            }
        }
        
        self.animator = animator
        return animator
    }
}
