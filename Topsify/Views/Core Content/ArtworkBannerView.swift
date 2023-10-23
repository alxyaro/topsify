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

    private let detailsView = BannerDetailsView()
    private let actionBarView = BannerActionBarView()

    private var artworkPlaceholderViewTopConstraint: NSLayoutConstraint?
    private var scrollAmount: CGFloat = 0
    private var disposeBag = DisposeBag()

    required init(frame: CGRect) {
        super.init(frame: frame)

        directionalLayoutMargins = .init(horizontal: 16, vertical: 0)

        addSubview(artworkPlaceholderView)
        artworkPlaceholderView.useAutoLayout()
        artworkPlaceholderViewTopConstraint = artworkPlaceholderView.topAnchor.constraint(equalTo: topAnchor).isActive(true)
        artworkPlaceholderView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        artworkPlaceholderView.leadingAnchor.constraint(greaterThanOrEqualTo: layoutMarginsGuide.leadingAnchor).isActive = true

        addSubview(artworkView)

        addSubview(detailsView)
        detailsView.constrainEdges(to: layoutMarginsGuide, excluding: .vertical)
        detailsView.topAnchor.constraint(equalTo: artworkPlaceholderView.bottomAnchor, constant: 16).isActive = true

        addSubview(actionBarView)
        actionBarView.constrainEdges(to: layoutMarginsGuide, excluding: .top, withPriorities: .forCellSizing)
        actionBarView.topAnchor.constraint(equalTo: detailsView.bottomAnchor).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateArtworkView()
    }

    @available(*, unavailable)
    override func configure(gradientColor: UIColor, scrollAmountPublisher: AnyPublisher<CGFloat, Never>) {}

    func configure(
        with viewModel: ArtworkBannerViewModel,
        scrollAmountPublisher: AnyPublisher<CGFloat, Never>,
        topInset: CGFloat,
        playButton: PlayButton
    ) {
        disposeBag = DisposeBag()

        super.configure(gradientColor: viewModel.accentColor.uiColor, scrollAmountPublisher: scrollAmountPublisher)

        artworkPlaceholderViewTopConstraint?.constant = topInset + 12
        artworkView.configure(with: viewModel.artworkURL)

        detailsView.configure(
            title: viewModel.title,
            description: viewModel.description,
            userAttribution: viewModel.userAttribution,
            details: viewModel.details
        )
        actionBarView.configure(with: viewModel.actionBarViewModel, playButton: playButton)

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
}

extension ArtworkBannerView: TopBarVisibilityControllingViewProviding {

    var topBarVisibilityControllingView: UIView? {
        detailsView.topBarVisibilityControllingView
    }
}
