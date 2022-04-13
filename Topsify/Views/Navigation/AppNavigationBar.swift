//
//  AppNavigationBar.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-10.
//

import UIKit

class AppNavigationBar: UIView {
    private static let titleAnimationMoveDelta: CGFloat = 45
    
    private var currentViewController: UIViewController?
    
    private let backArrow: UIImageView = {
        let arrow = UIImageView()
        arrow.image = UIImage(systemName: "chevron.left", withConfiguration: UIImage.SymbolConfiguration(pointSize: 19, weight: .bold))
        arrow.tintColor = .appTextPrimary
        arrow.translatesAutoresizingMaskIntoConstraints = false
        // TODO: make into custom over-arching component
        arrow.widthAnchor.constraint(equalToConstant: 30).isActive = true
        arrow.heightAnchor.constraint(equalToConstant: 40).isActive = true
        arrow.contentMode = .center
        return arrow
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
        stack.spacing = 5
        stack.alignment = .center
        return stack
    }()
    
    init() {
        super.init(frame: .zero)
        
        backgroundColor = .appBackground.withAlphaComponent(0.1)
        preservesSuperviewLayoutMargins = true
        
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
        
        addSubview(rootStackView)
        rootStackView.translatesAutoresizingMaskIntoConstraints = false
        rootStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true
        rootStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor).isActive = true
        rootStackView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor).isActive = true
        rootStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        rootStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // prevent back arrow & buttons from being shrunk
        backArrow.setContentCompressionResistancePriority(.required, for: .horizontal)
        buttonStackView.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func calcVerticalPosition(for controller: UIViewController) -> CGFloat {
        guard let scrollView = (controller as? AppNavigableController)?.mainScrollView else {
            return 0
        }
        
        var offset = scrollView.contentOffset.y + scrollView.adjustedContentInset.top
        if offset > 0 {
            // scroll view bounces or pull-downs should be ignored
            offset = 0
        }
        if offset < -self.bounds.height {
            offset = self.bounds.height
        }
        
        return offset
    }
    
    func update(for viewController: UIViewController, isRoot: Bool) {
        let navigable = viewController as? AppNavigableController
        
        backArrow.isHidden = isRoot
        titleLabel.text = viewController.navigationItem.title ?? "Untitled"
        for button in buttonStackView.arrangedSubviews {
            buttonStackView.removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        for button in navigable?.navBarButtons ?? [] {
            buttonStackView.addArrangedSubview(button)
        }
        
        frame = CGRect(x: frame.minX, y: calcVerticalPosition(for: viewController), width: frame.width, height: frame.height)
    }
    
    typealias TransitionContext = (fromVC: UIViewController, toVC: UIViewController, containerView: UIView)
    
    func pushTransition(using context: TransitionContext, animator: UIViewPropertyAnimator) {
        // record previous state
        let prevFrame = frame
        let prevBackArrowIsHidden = backArrow.isHidden
        let prevTitleLabel = titleLabel.snapshotView(afterScreenUpdates: false)
        prevTitleLabel?.frame = titleLabel.convert(titleLabel.bounds, to: self)
        let prevButtonStackView = buttonStackView.snapshotView(afterScreenUpdates: false)
        prevButtonStackView?.frame = buttonStackView.convert(buttonStackView.bounds, to: self)
        
        // update state
        update(for: context.toVC, isRoot: false)
        setNeedsLayout()
        layoutIfNeeded()
        
        // add temp snapshot views
        if prevTitleLabel != nil {
            addSubview(prevTitleLabel!)
        }
        if prevButtonStackView != nil {
            addSubview(prevButtonStackView!)
        }
        
        // perform animations
        if prevBackArrowIsHidden {
            backArrow.alpha = 0
            backArrow.frame = backArrow.frame.offsetBy(dx: Self.titleAnimationMoveDelta/2, dy: 0)
            animator.addAnimations { [unowned self] in
                backArrow.alpha = 1
                backArrow.frame = backArrow.frame.offsetBy(dx: -Self.titleAnimationMoveDelta/2, dy: 0)
            }
        }
        
        titleLabel.alpha = 0
        let titleTargetFrame = titleLabel.frame
        titleLabel.frame = titleLabel.frame.offsetBy(dx: Self.titleAnimationMoveDelta, dy: 0)
        animator.addAnimations { [unowned self] in
            if let prevTitleLabel = prevTitleLabel {
                prevTitleLabel.alpha = 0
                prevTitleLabel.frame = prevTitleLabel.frame.offsetBy(dx: -Self.titleAnimationMoveDelta, dy: 0)
            }
            titleLabel.alpha = 1
            titleLabel.frame = titleTargetFrame
        }
        
        buttonStackView.alpha = 0
        animator.addAnimations { [unowned self] in
            prevButtonStackView?.alpha = 0
            buttonStackView.alpha = 1
        }
        
        let newFrame = frame
        frame = prevFrame
        animator.addAnimations { [unowned self] in
            frame = newFrame
        }
        
        animator.addCompletion { pos in
            if pos == .end {
                self.currentViewController = context.toVC
            }
            prevTitleLabel?.removeFromSuperview()
            prevButtonStackView?.removeFromSuperview()
        }
    }
    
    func popTransition(using context: UIViewControllerContextTransitioning, animator: UIViewPropertyAnimator) {
        
    }
}
