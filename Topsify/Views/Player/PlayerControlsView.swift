// Created by Alex Yaro on 2023-03-25.

import UIKit

final class PlayerControlsView: UIView {
    static let insets = PlayerSliderContainerView.insets
    private static let buttonPadding = NSDirectionalEdgeInsets(uniform: 10)

    private let slider = PlayerSliderContainerView()

    private let shuffleButton = createButton(icon: "Icons/shuffle", scale: 1.2)
    private let previousButton = createButton(icon: "Icons/previous", scale: 1.1)
    private let playPauseButton = createButton(icon: "Icons/playCircle", scale: 2.7)
    private let nextButton = createButton(icon: "Icons/next", scale: 1.1)
    private let repeatButton = createButton(icon: "Icons/repeat", scale: 1.2)

    private let viewModel: PlayerControlsViewModel

    init(viewModel: PlayerControlsViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        bindViewModel()
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
        ]

        let buttonsStackView = UIStackView(arrangedSubviews: buttonViews)
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .equalSpacing
        buttonsStackView.alignment = .center
        buttonsStackView.directionalLayoutMargins = Self.buttonPadding
        buttonsStackView.isLayoutMarginsRelativeArrangement = true

        // In case spacing is tight, we want to arrange subviews for better hit testing
        // (given that we're using the ExpandedTouchView-s)
        buttonsStackView.bringSubviewToFront(previousButton)
        buttonsStackView.bringSubviewToFront(nextButton)
        buttonsStackView.bringSubviewToFront(playPauseButton)

        let mainStackView = UIStackView(arrangedSubviews: [
            OverhangingView(slider, overhang: PlayerSliderContainerView.insets),
            OverhangingView(buttonsStackView, overhang: Self.buttonPadding)
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 8
        mainStackView.directionalLayoutMargins = PlayerSliderContainerView.insets
        mainStackView.isLayoutMarginsRelativeArrangement = true

        addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview()

        semanticContentAttribute = .playback
    }

    private func bindViewModel() {
        viewModel.bind(inputs: .init(
            tappedNextButton: nextButton.tapPublisher,
            tappedPreviousButton: previousButton.tapPublisher
        ))
    }

    private static func createButton(icon: String, scale: CGFloat) -> AppIconButton {
        AppIconButton(icon: icon, scale: scale, expandedTouchBoundary: buttonPadding.toNonDirectionalInsets())
    }
}
