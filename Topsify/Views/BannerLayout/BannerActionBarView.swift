// Created by Alex Yaro on 2023-10-06.

import UIKit

final class BannerActionBarView: UIView {

    private let sideButtonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 24
        return stackView
    }()

    private let shuffleButton: AppIconButton = {
        let button = AppIconButton(icon: "Icons/shuffle")
        button.iconScale = 1.2
        button.tintColor = .secondaryIcon
        return button
    }()

    private let playButtonPlaceholderView: UIView = {
        let view = UIView()
        view.constrainDimensions(uniform: PlayButton.size)
        return view
    }()

    private var disposeBag = DisposeBag()

    init() {
        super.init(frame: .zero)

        let bottomButtonsStack = UIStackView(arrangedSubviews: [
            sideButtonsStackView,
            SpacerView(),
            shuffleButton,
            playButtonPlaceholderView
        ])
        bottomButtonsStack.axis = .horizontal
        bottomButtonsStack.alignment = .center
        bottomButtonsStack.spacing = 24
        bottomButtonsStack.setCustomSpacing(18, after: shuffleButton)

        addSubview(bottomButtonsStack)
        bottomButtonsStack.constrainEdgesToSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        with viewModel: BannerActionBarViewModel,
        playButton: PlayButton?
    ) {
        disposeBag = DisposeBag()

        sideButtonsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        for buttonModel in viewModel.sideButtons {
            let button = createSideButton(for: buttonModel.buttonType)

            button.tapPublisher
                .sink(receiveValue: buttonModel.onTap)
                .store(in: &disposeBag)

            sideButtonsStackView.addArrangedSubview(button)
        }

        viewModel.shuffleButtonVisibility.apply(to: shuffleButton, disposeBag: &disposeBag)

        if let playButton {
            playButtonPlaceholderView.isHidden = false
            playButton.constrainVertically(with: playButtonPlaceholderView.centerYAnchor)
        } else {
            playButtonPlaceholderView.isHidden = true
        }
    }

    private func createSideButton(for buttonType: BannerActionBarViewModel.SideButtonType) -> AppButton {
        switch buttonType {
        case .save:
            return Self.createIconButton(icon: "Icons/save")
        case .download:
            return Self.createIconButton(icon: "Icons/download")
        case .options:
            return Self.createIconButton(icon: "Icons/options")
        case .follow(let isFollowing):
            let text = isFollowing ? NSLocalizedString("Following", comment: "Button text") : NSLocalizedString("Follow", comment: "Button text")
            let button = AppTextButton(text: text, style: isFollowing ? .primary : .secondary, size: .small)
            return button
        }
    }

    private static func createIconButton(icon: String) -> AppIconButton {
        let icon = AppIconButton(icon: icon)
        icon.constrainHeight(to: 24)
        icon.tintColor = .secondaryIcon
        return icon
    }
}
