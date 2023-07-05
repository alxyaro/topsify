// Created by Alex Yaro on 2023-06-19.

import UIKit

final class AppIconButton: AppButton {

    private let iconImageView: IconImageView = {
        let view = IconImageView()
        view.tintColor = .primaryIcon
        view.setContentHuggingPriority(.required, for: .horizontal)
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.contentMode = .scaleAspectFit
        return view
    }()

    override var tintColor: UIColor! {
        didSet {
            iconImageView.tintColor = tintColor
        }
    }

    var icon: String {
        didSet {
            updateIcon()
        }
    }

    init(
        icon: String,
        scale: CGFloat = 1,
        size: CGSize? = nil,
        expandedTouchBoundary: UIEdgeInsets = .init(uniform: 8)
    ) {
        self.icon = icon

        iconImageView.scale = scale

        if let size {
            let contentView = UIView()
            contentView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
            contentView.heightAnchor.constraint(equalToConstant: size.height).isActive = true

            super.init(contentView: contentView, expandedTouchBoundary: expandedTouchBoundary)

            contentView.addSubview(iconImageView)
            iconImageView.constrainInCenterOfSuperview()
        } else {
            super.init(contentView: iconImageView, expandedTouchBoundary: expandedTouchBoundary)
        }

        updateIcon()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
}

private class IconImageView: UIImageView {
    var scale: CGFloat = 0

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
