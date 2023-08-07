// Created by Alex Yaro on 2023-08-05.

import Combine
import UIKit

final class ArtworkBannerView: BannerView {

    private let artworkView = RemoteImageView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 24, weight: .bold)
        label.numberOfLines = 1
        return label
    }()

    private let artistAvatarImageView: RemoteImageView = {
        let view = RemoteImageView()
        view.constrainDimensions(uniform: 20)
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()

    private let artistsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 13, weight: .bold)
        label.numberOfLines = 1
        return label
    }()

    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextSecondary
        label.font = .appFont(ofSize: 13)
        label.numberOfLines = 1
        return label
    }()

    private let saveButton = createSideButton(icon: "Icons/save")
    private let downloadButton = createSideButton(icon: "Icons/download")
    private let optionsButton = createSideButton(icon: "Icons/options")

    private let shuffleButton = AppIconButton(icon: "Icons/shuffle", scale: 1.2)

    private let playButtonPlaceholderView: UIView = {
        let view = UIView()
        view.constrainDimensions(uniform: PlayButton.size)
        return view
    }()

    required init(frame: CGRect) {
        super.init(frame: frame)

        downloadButton.isEnabled = false

        // FIXME: lagging when banner is stretching (too many layouts, or layout object issue? try with standard compositional layout)
        // 25% or so CPU when actively scrolling is okay, but maybe it can be optimized further by making regular cells fixed-height

        titleLabel.text = FakeAlbums.catchTheseVibes.title
        artistsLabel.text = FakeUsers.pnbRock.name
        artistAvatarImageView.configure(with: FakeUsers.pnbRock.avatarURL)
        detailsLabel.text = "Album \u{2022} 2017"

        directionalLayoutMargins = .init(horizontal: 16, vertical: 0)

        // TODO: remove temp
        heightAnchor.constraint(greaterThanOrEqualToConstant: 450).priority(.justLessThanRequired).isActive = true

        let artistRowStack = UIStackView(arrangedSubviews: [artistAvatarImageView, artistsLabel])
        artistRowStack.axis = .horizontal
        artistRowStack.alignment = .center
        artistRowStack.spacing = 8

        let descriptionStack = UIStackView(arrangedSubviews: [titleLabel, artistRowStack, detailsLabel])
        descriptionStack.axis = .vertical
        descriptionStack.alignment = .leading
        descriptionStack.spacing = 8
        descriptionStack.setCustomSpacing(4, after: titleLabel)

        addSubview(descriptionStack)
        descriptionStack.useAutoLayout()
        descriptionStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor).isActive = true

        let bottomButtonsStack = UIStackView(arrangedSubviews: [
            saveButton,
            downloadButton,
            optionsButton,
            SpacerView(),
            shuffleButton,
            playButtonPlaceholderView
        ])
        bottomButtonsStack.axis = .horizontal
        bottomButtonsStack.alignment = .center
        bottomButtonsStack.spacing = 24
        bottomButtonsStack.setCustomSpacing(18, after: shuffleButton)
        bottomButtonsStack.directionalLayoutMargins = .horizontal(16)
        bottomButtonsStack.isLayoutMarginsRelativeArrangement = true

        addSubview(bottomButtonsStack)
        bottomButtonsStack.constrainEdgesToSuperview(excluding: .top)
        bottomButtonsStack.topAnchor.constraint(equalTo: descriptionStack.bottomAnchor).isActive = true
    }

    @available(*, unavailable)
    override func configure(gradientColor: UIColor, scrollDownAmountPublisher: AnyPublisher<CGFloat, Never>) {}

    func configure(scrollDownAmountPublisher: AnyPublisher<CGFloat, Never>, topInset: CGFloat, playButton: PlayButton) {
        super.configure(gradientColor: .red.withAlphaComponent(0.2), scrollDownAmountPublisher: scrollDownAmountPublisher)
        playButton.centerYAnchor.constraint(greaterThanOrEqualTo: playButtonPlaceholderView.centerYAnchor).isActive = true
    }

    static func createSideButton(icon: String) -> AppIconButton {
        let icon = AppIconButton(icon: icon)
        icon.constrainHeight(to: 24)
        icon.tintColor = .secondaryIcon
        return icon
    }
}
