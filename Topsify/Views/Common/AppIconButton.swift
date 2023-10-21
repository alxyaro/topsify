// Created by Alex Yaro on 2023-06-19.

import UIKit

class AppIconButton: AppButton {

    override var tintColor: UIColor? {
        didSet {
            iconImageView.tintColor = tintColor
        }
    }

    var icon: String {
        didSet {
            updateIconWithTransition()
        }
    }

    var iconScale: CGFloat {
        get {
            iconImageView.scale
        }
        set {
            iconImageView.scale = newValue
        }
    }

    var iconHorizontalPadding: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    var iconVerticalPadding: CGFloat = 0 {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    var iconPosition: CGPoint = .init(x: 0.5, y: 0.5) {
        didSet {
            setNeedsLayout()
        }
    }

    var hasRoundedCorners: Bool = false {
        didSet {
            updateRoundedCorners()
        }
    }

    var iconFrame: CGRect {
        iconImageView.frame
    }

    let iconLayoutGuide = UILayoutGuide()

    private let iconImageView: IconImageView = {
        let view = IconImageView()
        view.tintColor = .primaryIcon
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.contentMode = .scaleAspectFit
        return view
    }()

    private let iconCenterXConstraint: NSLayoutConstraint
    private let iconCenterYConstraint: NSLayoutConstraint

    init(
        icon: String,
        expandedTouchBoundary: UIEdgeInsets = .init(uniform: 8)
    ) {
        self.icon = icon

        let contentView = UIView()
        contentView.addSubview(iconImageView)
        iconCenterXConstraint = iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive(true)
        iconCenterYConstraint = iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive(true)

        super.init(contentView: contentView, expandedTouchBoundary: expandedTouchBoundary)

        iconImageView.addLayoutGuide(iconLayoutGuide)
        iconImageView.constrainEdges(to: iconLayoutGuide)

        requireIntrinsicDimensions()
        updateIcon()
    }

    override var intrinsicContentSize: CGSize {
        iconImageView.intrinsicContentSize.expanded(byWidth: iconHorizontalPadding * 2, height: iconVerticalPadding * 2)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateIconPositionConstraints()
        updateRoundedCorners()
    }

    private func updateIconPositionConstraints() {
        let horizontalSpacingAroundIcon = frame.width - iconImageView.intrinsicContentSize.width
        let verticalSpacingAroundIcon = frame.height - iconImageView.intrinsicContentSize.height
        let offsetX = -horizontalSpacingAroundIcon * 0.5 + horizontalSpacingAroundIcon * iconPosition.x.clamped(to: 0...1)
        let offsetY = -verticalSpacingAroundIcon * 0.5 + verticalSpacingAroundIcon * iconPosition.y.clamped(to: 0...1)

        iconCenterXConstraint.constant = offsetX
        iconCenterYConstraint.constant = offsetY
        layoutIfNeeded()
    }

    private func updateIconWithTransition() {
        if UIView.areAnimationsEnabled {
            UIView.transition(with: iconImageView, duration: 0.2, options: [.transitionCrossDissolve, .beginFromCurrentState]) { [weak self] in
                self?.updateIcon()
            }
        } else {
            updateIcon()
        }
    }

    private func updateIcon() {
        iconImageView.image = UIImage(named: icon)
    }

    private func updateRoundedCorners() {
        guard hasRoundedCorners else { return }
        let cornerRadius = max(frame.width / 2, frame.height / 2)
        contentView.layer.cornerRadius = cornerRadius
    }
}

private class IconImageView: UIImageView {
    var scale: CGFloat = 1

    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if size.width < 0 || size.height < 0 {
            size = .zero
        }
        return .init(
            width: size.width * scale,
            height: size.height * scale
        )
    }
}
