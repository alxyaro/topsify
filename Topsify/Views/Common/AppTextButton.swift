// Created by Alex Yaro on 2023-08-26.

import UIKit

class AppTextButton: AppButton {

    struct Style {
        static let primary = Style(backgroundStyle: .outlined(.primaryButtonColor), textColor: .primaryButtonColor)
        static let secondary = Style(backgroundStyle: .outlined(.primaryButtonColor.withAlphaComponent(0.4)), textColor: .primaryButtonColor)

        enum BackgroundStyle {
            case outlined(UIColor)
            case filled(UIColor)
        }

        let backgroundStyle: BackgroundStyle
        let textColor: UIColor
    }

    enum Size {
        case small
        case regular
    }

    var text: String? {
        get {
            textLabel.text
        }
        set {
            textLabel.text = newValue
        }
    }

    var style: Style {
        didSet {
            updateViewStyleAndSize()
        }
    }

    var size: Size {
        didSet {
            updateViewStyleAndSize()
        }
    }

    private let textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()

    private let heightConstraint: NSLayoutConstraint

    init(
        text: String,
        style: Style,
        size: Size = .regular
    ) {
        self.style = style
        self.size = size

        let contentView = UIView()
        heightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0).isActive(true)

        contentView.addSubview(textLabel)
        textLabel.constrainEdges(to: contentView.layoutMarginsGuide)

        super.init(contentView: contentView)

        self.text = text
        updateViewStyleAndSize()
    }

    private func updateViewStyleAndSize() {
        heightConstraint.constant = size.height
        contentView.layer.cornerRadius = size.height / 2
        contentView.directionalLayoutMargins = .horizontal(size.sidePadding)

        textLabel.textColor = style.textColor
        textLabel.font = size.font

        contentView.backgroundColor = .clear
        contentView.layer.borderWidth = 0
        switch style.backgroundStyle {
        case .filled(let backgroundColor):
            contentView.backgroundColor = backgroundColor
        case .outlined(let outlineColor):
            contentView.layer.borderWidth = size.outlineWidth
            contentView.layer.borderColor = outlineColor.cgColor
        }
    }
}

private extension AppTextButton.Size {

    var height: CGFloat {
        switch self {
        case .small:
            return 34
        case .regular:
            return 48
        }
    }

    var sidePadding: CGFloat {
        switch self {
        case .small:
            return 18
        case .regular:
            return 30
        }
    }

    var outlineWidth: CGFloat {
        switch self {
        case .small:
            return 1
        case .regular:
            return 2
        }
    }

    var font: UIFont {
        switch self {
        case .small:
            return .appFont(ofSize: 13, weight: .bold)
        case .regular:
            return .appFont(ofSize: 15, weight: .bold)
        }
    }
}

private extension UIColor {
    static let primaryButtonColor = UIColor(named: "Colors/Buttons/primaryButtonColor")!
}
