// Created by Alex Yaro on 2023-08-26.

import UIKit

class AppTextButton: AppButton {
    private static let height: CGFloat = 48

    struct Style {
        static let primary = Style(backgroundStyle: .filled(.appBackground), textColor: .primaryButtonColor)
        static let primaryOutlined = Style(backgroundStyle: .outlined(.primaryButtonColor), textColor: .primaryButtonColor)

        enum BackgroundStyle {
            case filled(UIColor)
            case outlined(UIColor)
        }

        let backgroundStyle: BackgroundStyle
        let textColor: UIColor
    }

    private let backgroundView: UIView = {
        let view = UIView()
        view.constrainHeight(to: height)
        view.layer.cornerRadius = height / 2
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .appFont(ofSize: 15, weight: .bold)
        return label
    }()

    init(
        title: String,
        style: Style
    ) {
        backgroundView.addSubview(titleLabel)
        titleLabel.constrainEdgesToSuperview(withInsets: .horizontal(30))

        switch style.backgroundStyle {
        case .filled(let backgroundColor):
            backgroundView.backgroundColor = backgroundColor
        case .outlined(let outlineColor):
            backgroundView.layer.borderWidth = 2
            backgroundView.layer.borderColor = outlineColor.withAlphaComponent(0.3).cgColor
        }

        titleLabel.text = title
        titleLabel.textColor = style.textColor

        super.init(contentView: backgroundView)
    }
}

private extension UIColor {
    static let primaryButtonColor = UIColor(named: "Colors/Buttons/primaryButtonColor")!
}
