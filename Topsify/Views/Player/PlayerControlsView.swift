// Created by Alex Yaro on 2023-03-25.

import UIKit

final class PlayerControlsView: UIView {
    private static let buttonPadding: CGFloat = 10
    static let insets = NSDirectionalEdgeInsets(horizontal: PlayerSliderContainerView.inset, vertical: buttonPadding)

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
        let buttonViews = [
            shuffleButton,
            previousButton,
            playPauseButton,
            nextButton,
            repeatButton
        ].map {
            ExpandedTouchView($0, expandedBy: .init(uniform: Self.buttonPadding))
        }

        let buttonsStackView = UIStackView(arrangedSubviews: buttonViews)
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .equalSpacing
        buttonsStackView.alignment = .center
        buttonsStackView.directionalLayoutMargins = .init(uniform: Self.buttonPadding)
        buttonsStackView.isLayoutMarginsRelativeArrangement = true

        // In case spacing is tight, we want to arrange subviews for better hit testing
        // (given that we're using the ExpandedTouchView-s)
        buttonsStackView.bringSubviewToFront(buttonViews[1]) // previousButton
        buttonsStackView.bringSubviewToFront(buttonViews[3]) // nextButton
        buttonsStackView.bringSubviewToFront(buttonViews[2]) // playPauseButton

        let mainStackView = UIStackView(arrangedSubviews: [
            OverhangingView(slider, horizontalOverhang: PlayerSliderContainerView.inset),
            OverhangingView(buttonsStackView, overhang: .init(uniform: Self.buttonPadding))
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 10
        mainStackView.directionalLayoutMargins = Self.insets
        mainStackView.isLayoutMarginsRelativeArrangement = true

        addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview()

        semanticContentAttribute = .playback
    }

    private static func createButton(icon: String, size: CGFloat) -> AppButton {
        let button = AppButton(icon: icon, size: size)
        button.constrainDimensions(uniform: size + 8)
        button.tintColor = .primaryIcon
        return button
    }
}
