// Created by Alex Yaro on 2023-03-25.

import UIKit

final class PlayerControlsView: UIView {

    private let slider = PlayerSliderContainerView()

    private let shuffleButton = createButton(icon: "shuffle", size: 24)

    private let previousButton = createButton(icon: "backward.end.fill", size: 30)

    private let playPauseButton = createButton(icon: "play.circle.fill", size: 65)

    private let nextButton = createButton(icon: "forward.end.fill", size: 30)

    private let repeatButton = createButton(icon: "repeat", size: 24)

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let buttonsStackView = UIStackView(arrangedSubviews: [
            shuffleButton,
            previousButton,
            playPauseButton,
            nextButton,
            repeatButton
        ])
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .equalSpacing
        buttonsStackView.alignment = .center

        let mainStackView = UIStackView(arrangedSubviews: [
            OverhangingView(slider, horizontalOverhang: PlayerSliderContainerView.inset),
            buttonsStackView
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 10
        mainStackView.directionalLayoutMargins = .init(horizontal: PlayerSliderContainerView.inset, vertical: 0)
        mainStackView.isLayoutMarginsRelativeArrangement = true

        addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview(withInsets: .init(horizontal: 24 - PlayerSliderContainerView.inset, vertical: 0))
    }

    private static func createButton(icon: String, size: CGFloat) -> AppButton {
        let button = AppButton(
            icon: UIImage(
                systemName: icon,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: size)
            )
        )
        button.constrainDimensions(uniform: size + 8)
        button.tintColor = .primaryIcon
        return button
    }
}
