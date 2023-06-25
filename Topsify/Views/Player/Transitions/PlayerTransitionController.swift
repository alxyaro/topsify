// Created by Alex Yaro on 2023-05-28.

import UIKit

class PlayerTransitionController: NSObject, UIViewControllerAnimatedTransitioning {
    private static let playerCornerRadius: CGFloat = 24

    enum Transition {
        case appear
        case disappear

        var isAppear: Bool {
            self == .appear
        }

        var isDisappear: Bool {
            self == .disappear
        }
    }

    private let transition: Transition
    private let playBarView: PlayBarView

    private var activeAnimator: UIViewPropertyAnimator?

    init(
        transition: Transition,
        playBarView: PlayBarView
    ) {
        self.transition = transition
        self.playBarView = playBarView
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.35
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let animator = interruptibleAnimator(using: transitionContext)
        if !animator.isRunning {
            animator.startAnimation()
        }
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if let activeAnimator { return activeAnimator }
        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext), curve: .easeInOut)
        animator.isUserInteractionEnabled = false

        let transition = self.transition
        let containerView = transitionContext.containerView
        let playBarView = self.playBarView

        guard
            let playerVC = transitionContext.viewController(forKey: transition.isAppear ? .to : .from),
            let playerView = playerVC.view
        else { return animator }

        let visiblePlayerFrame = transition.isAppear ? transitionContext.finalFrame(for: playerVC) : playerView.frame
        let playBarViewFrameInContainerView = playBarView.convert(playBarView.bounds, to: containerView)

        let playerContainerView = UIView()
        containerView.addSubview(playerContainerView)
        playerContainerView.addSubview(playerView)

        let totalTranslationDistance = playBarViewFrameInContainerView.minY - visiblePlayerFrame.minY

        // MARK: - Player Container Mask

        let playerContainerMaskView = UIView()
        playerContainerMaskView.backgroundColor = .black
        playerContainerView.mask = playerContainerMaskView

        let playBarViewFrameInPlayerContainerView = playBarView.convert(playBarView.bounds, to: playerContainerView)
        let playerViewFrameInPlayerContainerView = containerView.convert(visiblePlayerFrame, to: playerContainerView)

        if transition.isAppear {
            playerContainerMaskView.frame = playBarViewFrameInPlayerContainerView

            animator.addAnimations {
                UIView.animateKeyframes(withDuration: UIView.inheritedAnimationDuration, delay: 0) {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
                        playerContainerMaskView.frame = playBarViewFrameInPlayerContainerView.expanded(top: totalTranslationDistance * 0.1)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.4) {
                        playerContainerMaskView.frame = playerViewFrameInPlayerContainerView.expanded(top: -totalTranslationDistance * 0.5)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                        playerContainerMaskView.frame = playerViewFrameInPlayerContainerView
                    }
                }
            }

            playerContainerMaskView.layer.cornerRadius = playBarView.layer.cornerRadius

            animator.addAnimations {
                UIView.animateKeyframes(withDuration: UIView.inheritedAnimationDuration, delay: 0) {
                    UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.3) {
                        playerContainerMaskView.layer.cornerRadius = Self.playerCornerRadius
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) {
                        playerContainerMaskView.layer.cornerRadius = 0
                    }
                }
            }
        } else {
            playerContainerMaskView.frame = playerViewFrameInPlayerContainerView

            animator.addAnimations {
                UIView.animateKeyframes(withDuration: UIView.inheritedAnimationDuration, delay: 0) {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                        playerContainerMaskView.frame = playerViewFrameInPlayerContainerView.expanded(top: -totalTranslationDistance * 0.5)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.4) {
                        playerContainerMaskView.frame = playBarViewFrameInPlayerContainerView.expanded(top: totalTranslationDistance * 0.1)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) {
                        playerContainerMaskView.frame = playBarViewFrameInPlayerContainerView
                    }
                }
            }

            playerContainerMaskView.layer.cornerRadius = 0

            animator.addAnimations {
                UIView.animateKeyframes(withDuration: UIView.inheritedAnimationDuration, delay: 0) {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
                        playerContainerMaskView.layer.cornerRadius = Self.playerCornerRadius
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.3) {
                        playerContainerMaskView.layer.cornerRadius = playBarView.layer.cornerRadius
                    }
                }
            }
        }

        // MARK: - Player Frame

        let playerViewTranslationPosition = playBarViewFrameInContainerView.minY

        if transition.isAppear {
            playerView.frame = visiblePlayerFrame
            playerView.frame.origin.y = playerViewTranslationPosition
        }

        animator.addAnimations {
            playerView.frame.origin.y = transition.isAppear ? visiblePlayerFrame.origin.y : playerViewTranslationPosition
        }

        // MARK: - Player Opacity

        if transition.isAppear {
            playerView.alpha = 0
            animator.addAnimations(relativeDuration: 0.1, position: .start) {
                playerView.alpha = 1
            }
        } else {
            animator.addAnimations(relativeDuration: 0.1, position: .end) {
                playerView.alpha = 0
            }
        }

        // MARK: - PlayBar Frame

        let normalPlayBarViewFrame = playBarView.frame
        animator.addCompletion { _ in
            playBarView.frame = normalPlayBarViewFrame
        }
        if transition.isAppear {
            animator.addAnimations {
                UIView.animateKeyframes(withDuration: UIView.inheritedAnimationDuration, delay: 0) {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.1) {
                        playBarView.frame = normalPlayBarViewFrame.offsetBy(dx: 0, dy: -totalTranslationDistance * 0.1)
                    }
                }
            }
        } else {
            animator.addAnimations {
                UIView.animateKeyframes(withDuration: UIView.inheritedAnimationDuration, delay: 0) {
                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.9) {
                        /// We have to set the initial animation frame here. Setting the initial frame before the `addAnimations` call
                        /// strangely does not work, the view just sits at the final frame. This happens regardless of using Auto Layout or
                        /// direct frame manipulation. The issue does not occur if `animateKeyframes` is not used.
                        playBarView.frame = normalPlayBarViewFrame.offsetBy(dx: 0, dy: -totalTranslationDistance * 0.1)
                    }
                    UIView.addKeyframe(withRelativeStartTime: 0.9, relativeDuration: 0.1) {
                        playBarView.frame = normalPlayBarViewFrame
                    }
                }
            }
        }

        // MARK: - Cleanup

        animator.addCompletion { position in
            let didComplete = position == .end

            containerView.addSubview(playerView)
            playerContainerView.removeFromSuperview()

            if didComplete {
                if transition.isDisappear {
                    playerView.removeFromSuperview()
                }
            } else {
                if transition.isAppear {
                    playerView.removeFromSuperview()
                }
            }

            transitionContext.completeTransition(didComplete)
        }

        activeAnimator = animator
        return animator
    }

    func animationEnded(_ transitionCompleted: Bool) {
        if let activeAnimator, activeAnimator.isRunning {
            activeAnimator.stopAnimation(false)
            // This conditional check is required to avoid a crash; see https://stackoverflow.com/a/59205289
            if activeAnimator.state == .stopped {
                activeAnimator.finishAnimation(at: transition.isAppear ? .end : .start)
            }
        }
        activeAnimator = nil
    }
}
