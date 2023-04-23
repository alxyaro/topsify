// Created by Alex Yaro on 2023-03-25.

import UIKit

final class PlayerControlsView: UIView {
    static let insets = PlayerSliderContainerView.insets
    private static let buttonPadding = NSDirectionalEdgeInsets(uniform: 10)

    private let slider = PlayerSliderContainerView()

    private let shuffleButton = createButton(icon: "shuffle", size: 24)
    private let previousButton = createButton(icon: "backward.end.fill", size: 30)
    private let playPauseButton = createButton(icon: "play.circle.fill", size: 65)
    private let nextButton = createButton(icon: "forward.end.fill", size: 30)
    private let repeatButton = createButton(icon: "repeat", size: 24)

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

    private static func createButton(icon: String, size: CGFloat) -> AppButton {
        AppButton(icon: icon, size: size, expandedTouchBoundary: buttonPadding.toNonDirectionalInsets())
    }
}
