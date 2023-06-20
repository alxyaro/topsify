// Created by Alex Yaro on 2023-03-27.

import UIKit

final class MarqueeView: UIView {

    private enum Direction {
        case forward
        case backward

        var opposite: Direction {
            switch self {
            case .forward: return .backward
            case .backward: return .forward
            }
        }
    }

    private let contentView: UIView
    private var lastContentViewBounds = CGRect.zero
    private let speedFactor: CGFloat
    private let boundaryDelay: TimeInterval
    private var offsetConstraint: NSLayoutConstraint!

    private let gradientSize: CGFloat
    /** The frame of this is expanded beyond the `MarqueeView`; see bounds `didSet` below. */
    private let gradientMaskView: HorizontalGradientMaskView

    private var activeAnimation: UIViewPropertyAnimator?
    private var activeBoundaryDelay: DispatchWorkItem?
    private var direction: Direction = .forward

    override var bounds: CGRect {
        didSet {
            // The vertical expansion is to allow text views to slightly extend outside the frame
            gradientMaskView.frame = bounds.expanded(horizontal: gradientSize, vertical: 10)
        }
    }

    init(
        _ contentView: UIView,
        speedFactor: CGFloat = 1,
        boundaryDelay: TimeInterval = 2,
        gradientSize: CGFloat = 12
    ) {
        self.contentView = contentView
        self.speedFactor = speedFactor
        self.boundaryDelay = boundaryDelay
        self.gradientSize = gradientSize
        self.gradientMaskView = .init(gradientSize: gradientSize)

        super.init(frame: .zero)

        addSubview(contentView)
        contentView.constrainEdgesToSuperview(excluding: .horizontal)
        contentView.widthAnchor.constraint(greaterThanOrEqualTo: widthAnchor).isActive = true
        offsetConstraint = contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive(true)

        mask = gradientMaskView
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reset() {
        activeAnimation?.stopAnimation(true)
        activeAnimation = nil
        activeBoundaryDelay?.cancel()
        activeBoundaryDelay = nil
        offsetConstraint.constant = 0

        attemptStart()
    }

    // MARK: - Lifecycle

    /// This will be called when `contentView` `bounds` or `intrinsicContentSize` changes.
    /// Therefore, we can determine if the animation need to be restarted based on the last recorded bounds.
    /// See https://stackoverflow.com/a/5330162 for context.
    override func layoutSubviews() {
        activeAnimation?.stopAnimation(true)
        super.layoutSubviews()

        // If the bounds of the contentView changed, reset the animation.
        // Otherwise, if the animation was active when layout occurred, resume it.
        if lastContentViewBounds != contentView.bounds {
            reset()
        } else if activeAnimation != nil {
            animate()
        }
        lastContentViewBounds = contentView.bounds
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        attemptStart()
    }

    // MARK: - Private Helpers

    private func attemptStart() {
        if superview != nil && activeAnimation == nil && activeBoundaryDelay == nil {
            delayThenAnimate()
        }
    }

    private func delayThenAnimate() {
        let workItem = DispatchWorkItem { [weak self] in
            self?.animate()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + boundaryDelay, execute: workItem)
        activeBoundaryDelay = workItem
    }

    private func animate() {
        if activeAnimation != nil {
            activeAnimation?.stopAnimation(true)
        }

        let hiddenDistance = contentView.frame.width - frame.width

        let distanceToTravel: CGFloat
        let targetOffset: CGFloat

        switch direction {
        case .forward:
            distanceToTravel = hiddenDistance + offsetConstraint.constant
            targetOffset = -hiddenDistance
        case .backward:
            distanceToTravel = -offsetConstraint.constant
            targetOffset = 0
        }

        layoutIfNeeded()

        let animation = UIViewPropertyAnimator(duration: distanceToTravel / max(1, speedFactor * 40), curve: .linear)
        animation.addAnimations { [weak self] in
            guard let self else { return }
            self.offsetConstraint.constant = targetOffset
            self.layoutIfNeeded()
        }
        animation.addCompletion { [weak self] position in
            guard let self else { return }
            if position == .end {
                self.direction = self.direction.opposite
            }
            self.activeAnimation = nil
            self.delayThenAnimate()
        }
        animation.startAnimation()
        activeAnimation = animation
    }
}
