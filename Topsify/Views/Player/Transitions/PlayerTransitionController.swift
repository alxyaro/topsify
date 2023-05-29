// Created by Alex Yaro on 2023-05-28.

import UIKit

class PlayerTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
    private static let playerCornerRadius: CGFloat = 24

    enum Animation {
        case appear
        case disappear

        var isAppear: Bool {
            self == .appear
        }

        var isDisappear: Bool {
            self == .disappear
        }
    }

    private let animation: Animation

    private var activeAnimator: UIViewPropertyAnimator?

    init(animation: Animation) {
        self.animation = animation
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if activeAnimator != nil { return }
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: .easeOut)
        animator.isUserInteractionEnabled = false

        let animation = self.animation
        let containerView = transitionContext.containerView

        guard
            let playerView = transitionContext.view(forKey: animation.isAppear ? .to : .from)
        else { return }

        if animation.isAppear {
            containerView.addSubview(playerView)
            playerView.frame = containerView.bounds
            playerView.frame.origin.y = playerView.frame.height
            playerView.layer.cornerRadius = Self.playerCornerRadius
            playerView.layer.maskedCorners = .top
        }

        animator.addAnimations {
            playerView.frame.origin.y = animation.isAppear ? 0 : playerView.frame.height
        }

        animator.addAnimations {
            UIView.animateKeyframes(withDuration: UIView.inheritedAnimationDuration, delay: 0) {
                if animation.isAppear {
                    // Remove corner radius near the end of the appear animation
                    UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2) {
                        playerView.layer.cornerRadius = 0
                    }
                } else {
                    // Re-add corner radius at the start of the disappear animation
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.2) {
                        playerView.layer.cornerRadius = Self.playerCornerRadius
                    }
                }
            }
        }

        animator.addCompletion { position in
            let didComplete = position == .end

            if didComplete {
                if animation.isDisappear {
                    playerView.removeFromSuperview()
                }
            } else {
                if animation.isAppear {
                    playerView.removeFromSuperview()
                }
            }

            transitionContext.completeTransition(didComplete)
        }

        animator.startAnimation()
        activeAnimator = animator
    }

    func animationEnded(_ transitionCompleted: Bool) {
        if let activeAnimator, activeAnimator.isRunning {
            activeAnimator.stopAnimation(false)
            // This conditional check is required to avoid a crash; see https://stackoverflow.com/a/59205289
            if activeAnimator.state == .stopped {
                activeAnimator.finishAnimation(at: animation.isAppear ? .end : .start)
            }
        }
        activeAnimator = nil
    }
}
