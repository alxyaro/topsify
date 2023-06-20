// Created by Alex Yaro on 2023-06-19.

import UIKit

final class AppIconButton: AppButton {

    private let iconImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .primaryIcon
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

    init(icon: String, size: CGFloat, buttonSize: CGFloat? = nil) {
        self.icon = icon

        super.init()

        iconImageView.constrainDimensions(uniform: size)
        if let buttonSize {
            constrainDimensions(uniform: buttonSize)
        }

        contentView.addSubview(iconImageView)
        iconImageView.constrainInCenter(of: contentView)
        iconImageView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor).isActive = true
        iconImageView.heightAnchor.constraint(lessThanOrEqualTo: contentView.heightAnchor).isActive = true

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
