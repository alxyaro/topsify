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

        let contentView = UIView()
        super.init(contentView: contentView, expandedTouchBoundary: expandedTouchBoundary)

        if let size {
            contentView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
            contentView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }

        contentView.addSubview(iconImageView)
        iconImageView.constrainInCenterOfSuperview()

        updateIcon()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var intrinsicContentSize: CGSize {
        iconImageView.intrinsicContentSize
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

    override func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        superview?.invalidateIntrinsicContentSize()
    }

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
