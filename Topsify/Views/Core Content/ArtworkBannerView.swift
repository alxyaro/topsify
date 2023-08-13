// Created by Alex Yaro on 2023-08-05.

import Combine
import UIKit

final class ArtworkBannerView: BannerView {

    private let artworkPlaceholderView: UIView = {
        let view = UIView()
        view.useAutoLayout()
        view.widthAnchor.constraint(equalToConstant: 260).priority(.justLessThanRequired).isActive = true
        view.heightAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        return view
    }()

    private let artworkView: RemoteImageView = {
        let imageView = RemoteImageView()
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.4
        imageView.layer.shadowRadius = 25
        imageView.layer.shadowOffset = .zero
        return imageView
    }()

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

    private let shuffleButton: AppIconButton = {
        let button = AppIconButton(icon: "Icons/shuffle", scale: 1.2)
        button.tintColor = .secondaryIcon
        return button
    }()

    private let playButtonPlaceholderView: UIView = {
        let view = UIView()
        view.constrainDimensions(uniform: PlayButton.size)
        return view
    }()

    var viewManagingNavBarVisibility: UIView {
        titleLabel
    }

    private var artworkPlaceholderViewTopConstraint: NSLayoutConstraint?
    private var scrollAmount: CGFloat = 0
    private var disposeBag = DisposeBag()

    required init(frame: CGRect) {
        super.init(frame: frame)

        downloadButton.isEnabled = false

        artworkView.configure(with: FakeAlbums.catchTheseVibes.imageURL)
        titleLabel.text = FakeAlbums.catchTheseVibes.title
        artistsLabel.text = FakeUsers.pnbRock.name
        artistAvatarImageView.configure(with: FakeUsers.pnbRock.avatarURL)
        detailsLabel.text = "Album \u{2022} 2017"

        directionalLayoutMargins = .init(horizontal: 16, vertical: 0)

        addSubview(artworkPlaceholderView)
        artworkPlaceholderView.useAutoLayout()
        artworkPlaceholderViewTopConstraint = artworkPlaceholderView.topAnchor.constraint(equalTo: topAnchor).isActive(true)
        artworkPlaceholderView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        artworkPlaceholderView.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor).isActive = true

        addSubview(artworkView)

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
        descriptionStack.topAnchor.constraint(equalTo: artworkPlaceholderView.bottomAnchor, constant: 16).isActive = true
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

    override func layoutSubviews() {
        super.layoutSubviews()
        updateArtworkView()
    }

    @available(*, unavailable)
    override func configure(gradientColor: UIColor, scrollAmountPublisher: AnyPublisher<CGFloat, Never>) {}

    func configure(
        scrollAmountPublisher: AnyPublisher<CGFloat, Never>,
        topInset: CGFloat,
        playButton: PlayButton
    ) {
        super.configure(gradientColor: UIColor(hexString: FakeAlbums.catchTheseVibes.accentColorHex), scrollAmountPublisher: scrollAmountPublisher)

        disposeBag = DisposeBag()

        artworkPlaceholderViewTopConstraint?.constant = topInset + 12
        playButton.centerYAnchor.constraint(greaterThanOrEqualTo: playButtonPlaceholderView.centerYAnchor).isActive = true

        scrollAmountPublisher
            .sink { [weak self] scrollAmount in
                self?.scrollAmount = scrollAmount
                self?.updateArtworkView()
            }
            .store(in: &disposeBag)
    }

    private func updateArtworkView() {
        artworkView.frame = artworkPlaceholderView.frame
        artworkView.alpha = 1

        if scrollAmount < 0 {
            let maxGrowAmount = 2 * (artworkView.frame.minX - 16)
            let growScrollFactor: CGFloat = 0.4
            let growAmount = min(-scrollAmount * growScrollFactor, maxGrowAmount)

            artworkView.frame = artworkView.frame.expanded(by: growAmount / 2)
            artworkView.center.y -= -scrollAmount / 2
        } else {
            let maxShrinkAmount = artworkView.frame.width * 0.2
            let shrinkScrollFactor: CGFloat = 0.3
            let shrinkAmount = min(scrollAmount * shrinkScrollFactor, maxShrinkAmount)

            artworkView.frame = artworkView.frame.expanded(by: -shrinkAmount / 2)
            artworkView.center.y += scrollAmount - shrinkAmount / 2
            artworkView.alpha = 1 - (shrinkAmount / maxShrinkAmount)
        }

        artworkView.layer.shadowPath = UIBezierPath(rect: artworkView.bounds).cgPath
    }

    static func createSideButton(icon: String) -> AppIconButton {
        let icon = AppIconButton(icon: icon)
        icon.constrainHeight(to: 24)
        icon.tintColor = .secondaryIcon
        return icon
    }
}
