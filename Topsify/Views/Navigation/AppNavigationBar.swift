//
//  AppNavigationBar.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-10.
//

import UIKit

class AppNavigationBar: UIView {
    private static let height: CGFloat = 50
    private static let bottomPadding: CGFloat = 8
    private static let titleAnimationMoveDelta: CGFloat = 45
    
    weak var navigationController: AppNavigationController?
    
    private let statusBarBackgroundView = UIView()
    private let containerView = UIView()
    
    private let backArrow: UIView = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 19, weight: .bold)), for: .normal)
        button.tintColor = .appTextPrimary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.widthAnchor.constraint(equalToConstant: 35).isActive = true
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.contentMode = .center
        button.addTarget(self, action: #selector(handleBackButtonTap), for: .touchUpInside)
        return OverhangingView(button)
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 21, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 15
        stack.alignment = .center
        return stack
    }()
    
    init() {
        super.init(frame: .zero)
        
        preservesSuperviewLayoutMargins = true
        
        addSubview(statusBarBackgroundView)
        statusBarBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        statusBarBackgroundView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        statusBarBackgroundView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        statusBarBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        statusBarBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        statusBarBackgroundView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true
        
        insertSubview(containerView, belowSubview: statusBarBackgroundView)
        // note: explicitly not using Auto Layout for this view, but this anchor is still needed
        containerView.bottomAnchor.constraint(equalTo: bottomAnchor).priorityAdjustment(-1).isActive = true
        
        // ContentHuggingPriority doesn't seem to work on the nested stack view
        // so using this spacer view as a workaround
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow-1, for: .horizontal)
        
        let rootStackView = UIStackView(arrangedSubviews: [
            backArrow,
            titleLabel,
            spacerView,
            buttonStackView
        ])
        rootStackView.axis = .horizontal
        rootStackView.alignment = .center
        rootStackView.spacing = 5
        
        containerView.addSubview(rootStackView)
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        rootStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        rootStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -Self.bottomPadding).isActive = true
        rootStackView.heightAnchor.constraint(equalToConstant: Self.height).isActive = true
        
        // prevent back arrow & buttons from being shrunk
        backArrow.setContentCompressionResistancePriority(.required, for: .horizontal)
        buttonStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        containerView.frame.size.width = frame.width
        super.layoutSubviews()
    }
    
    override func safeAreaInsetsDidChange() {
        containerView.frame.size.height = safeAreaInsets.top + Self.height + Self.bottomPadding
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for view in [backArrow, buttonStackView] {
            let localPoint = convert(point, to: view)
            if view.point(inside: localPoint, with: event) {
                let hitView = view.hitTest(localPoint, with: event)
                // this check is to avoid hitting an empty area of the stack view
                if hitView is UIControl {
                    return hitView
                }
            }
        }
        if let navigable = navigationController?.topViewController as? AppNavigableController,
           navigable.isNavBarSticky {
            // if the nav bar is sticky, swallow all touch events as normal
            return super.hitTest(point, with: event)
        }
        return nil
    }
    
    @objc private func handleBackButtonTap() {
        guard navigationController?.animationActive == false else {
            return
        }
        navigationController?.popViewController(animated: true)
    }
    
    func getMaximumHeight() -> CGFloat {
        return safeAreaInsets.top + Self.height + Self.bottomPadding
    }
    
    func updatePosition(using viewController: UIViewController) {
        let navigable = viewController as? AppNavigableController
        let isSticky = navigable?.isNavBarSticky ?? false
        
        var scrollAmount: CGFloat = 0
        if let scrollView = navigable?.mainScrollView {
            scrollAmount = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        }
        
        var verticalOffset = isSticky ? 0 : -scrollAmount
        if verticalOffset > 0 {
            // scroll view bounces or pull-downs should be ignored
            verticalOffset = 0
        }
        if verticalOffset < -getMaximumHeight() {
            verticalOffset = -getMaximumHeight()
        }
        
        containerView.frame.origin.y = verticalOffset
        
        let backgroundOpacity = min(Self.height, scrollAmount)/Self.height
        let backgroundColor = UIColor.appBackground.withAlphaComponent(0.75 * backgroundOpacity)
        if isSticky {
            statusBarBackgroundView.backgroundColor = .clear
            containerView.backgroundColor = backgroundColor
        } else {
            statusBarBackgroundView.backgroundColor = backgroundColor
            containerView.backgroundColor = .clear
        }
    }
    
    func update(for viewController: UIViewController, isRoot: Bool, performLayout: Bool = false) {
        let navigable = viewController as? AppNavigableController
        
        backArrow.isHidden = isRoot
        titleLabel.text = viewController.navigationItem.title ?? "Untitled"
        titleLabel.alpha = 1
        if navigable?.navBarButtons != buttonStackView.arrangedSubviews {
            for button in buttonStackView.arrangedSubviews {
                buttonStackView.removeArrangedSubview(button)
                button.removeFromSuperview()
            }
            for button in navigable?.navBarButtons ?? [] {
                buttonStackView.addArrangedSubview(button)
            }
        }
        buttonStackView.alpha = 1
        
        updatePosition(using: viewController)
        
        setNeedsLayout()
        if performLayout {
            layoutIfNeeded()
        }
    }
    
    typealias TransitionContext = (fromVC: UIViewController, toVC: UIViewController, containerView: UIView)
    
    func transition(using context: UIViewControllerContextTransitioning, operation: UINavigationController.Operation, toRootVC: Bool, animator: UIViewPropertyAnimator) {
        let pushing = operation == .push
        
        // record previous state
        let prevStatusBarBackgroundViewBackgroundColor = statusBarBackgroundView.backgroundColor
        let prevContainerViewBackgroundColor = containerView.backgroundColor
        let prevContainerViewFrame = containerView.frame
        let prevBackArrowIsHidden = backArrow.isHidden
        let prevBackArrow = backArrow.snapshotView(afterScreenUpdates: false)
        prevBackArrow?.frame = backArrow.convert(backArrow.bounds, to: containerView)
        let prevTitleLabel = titleLabel.snapshotView(afterScreenUpdates: false)
        prevTitleLabel?.frame = titleLabel.convert(titleLabel.bounds, to: containerView)
        let prevButtonStackView = buttonStackView.snapshotView(afterScreenUpdates: false)
        prevButtonStackView?.frame = buttonStackView.convert(buttonStackView.bounds, to: containerView)
        
        // update state
        update(for: context.viewController(forKey: .to)!, isRoot: toRootVC, performLayout: true)
        
        // add temp snapshot views
        if prevTitleLabel != nil {
            containerView.addSubview(prevTitleLabel!)
        }
        if prevButtonStackView != nil {
            containerView.addSubview(prevButtonStackView!)
        }
        
        // perform animations
        
        let newStatusBarBackgroundViewBackgroundColor = statusBarBackgroundView.backgroundColor
        let newContainerViewBackgroundColor = containerView.backgroundColor
        statusBarBackgroundView.backgroundColor = prevStatusBarBackgroundViewBackgroundColor
        containerView.backgroundColor = prevContainerViewBackgroundColor
        animator.addAnimations { [unowned self] in
            statusBarBackgroundView.backgroundColor = newStatusBarBackgroundViewBackgroundColor
            containerView.backgroundColor = newContainerViewBackgroundColor
        }
        
        if prevBackArrowIsHidden && !backArrow.isHidden {
            backArrow.alpha = 0
            backArrow.frame = backArrow.frame.offsetBy(dx: Self.titleAnimationMoveDelta/2, dy: 0)
            animator.addAnimations { [unowned self] in
                backArrow.alpha = 1
                backArrow.frame = backArrow.frame.offsetBy(dx: -Self.titleAnimationMoveDelta/2, dy: 0)
            }
        } else if let prevBackArrow = prevBackArrow, !prevBackArrowIsHidden && backArrow.isHidden {
            containerView.addSubview(prevBackArrow)
            animator.addAnimations {
                prevBackArrow.alpha = 0
                prevBackArrow.frame = prevBackArrow.frame.offsetBy(dx: Self.titleAnimationMoveDelta/2, dy: 0)
            }
        }
        
        titleLabel.alpha = 0
        let titleTargetFrame = titleLabel.frame
        titleLabel.frame = titleLabel.frame.offsetBy(dx: Self.titleAnimationMoveDelta * (pushing ? 1 : -1), dy: 0)
        animator.addAnimations { [unowned self] in
            if let prevTitleLabel = prevTitleLabel {
                prevTitleLabel.alpha = 0
                prevTitleLabel.frame = prevTitleLabel.frame.offsetBy(dx: -Self.titleAnimationMoveDelta * (pushing ? 1 : -1), dy: 0)
            }
            titleLabel.alpha = 1
            titleLabel.frame = titleTargetFrame
        }
        
        buttonStackView.alpha = 0
        animator.addAnimations { [unowned self] in
            prevButtonStackView?.alpha = 0
            buttonStackView.alpha = 1
        }
        
        // When Auto Layout performs layout of the navigation bar, it forcefully sets
        // the frame to have a y=0; this is a problem as animations are performed as
        // displacements, and the following animation's starting point will be shifted
        // to the wrong place, causing a glitchy "jump" if the target frame has a y<0.
        // Presumably as the frame is set directly within the animation block, Auto
        // Layout kicks in right as the animation starts, and so you get that awful
        // jump. To work around this, I disable auto layout temporarily by setting
        // this flag to true, which prevents Auto Layout from making this adjustment.
        // The less-ideal alternative (imo) would be to move the navigation bar using
        // a changing topAnchor constraint; that would require a layoutIfNeeded() call
        // which is bound to mess up the animation further.
        //  UPDATE: no longer using Auto Layout for shifting the view (containerView)
        //  logic commented out but kept for future reference
        //containerView.translatesAutoresizingMaskIntoConstraints = true
        let newContainerViewFrame = containerView.frame
        containerView.frame = prevContainerViewFrame
        animator.addAnimations { [unowned self] in
            containerView.frame = newContainerViewFrame
        }
        
        animator.addCompletion { [unowned self] pos in
            //containerView.translatesAutoresizingMaskIntoConstraints = false
            if pos == .start, let fromVC = context.viewController(forKey: .from) {
                // revert to true state (due to cancellation, i.e. pos == .start)
                let returningToRoot = navigationController?.rootViewController == fromVC
                update(for: fromVC, isRoot: returningToRoot)
            }
            prevBackArrow?.removeFromSuperview()
            prevTitleLabel?.removeFromSuperview()
            prevButtonStackView?.removeFromSuperview()
        }
    }
}
