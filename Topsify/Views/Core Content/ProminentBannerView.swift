// Created by Alex Yaro on 2023-10-12.

import Combine
import UIKit

final class ProminentBannerView: BannerView {

    private let backgroundImageView: RemoteImageView = {
        let image = RemoteImageView()
        image.contentMode = .scaleAspectFill
        return image
    }()

    private lazy var backgroundImageContainerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true

        view.addSubview(backgroundImageView)
        backgroundImageView.constrainEdgesToSuperview(excluding: .bottom)
        backgroundImageView.widthAnchor.constraint(equalTo: backgroundImageView.heightAnchor).priority(.justLessThanRequired).isActive = true
        backgroundImageView.heightAnchor.constraint(greaterThanOrEqualTo: view.heightAnchor).isActive = true

        return view
    }()

    private let backgroundImageFramingView: UIView = {
        let view = UIView()
        view.constrainHeight(to: 270)
        return view
    }()

    private let titleGradientView = GradientFadeView(color: .black.withAlphaComponent(0.4), direction: .up)

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 42, weight: .bold)
        label.textColor = .appTextPrimary
        label.numberOfLines = 0
        return label
    }()

    private let detailsView = BannerDetailsView()
    private let actionBarView = BannerActionBarView()

    private var backgroundImageFramingViewTopConstraint: NSLayoutConstraint?
    private var scrollAmount: CGFloat = 0
    private var disposeBag = DisposeBag()

    required init(frame: CGRect) {
        super.init(frame: frame)

        directionalLayoutMargins = .init(horizontal: 16, vertical: 0)

        addSubview(backgroundImageContainerView)

        addSubview(backgroundImageFramingView)
        backgroundImageFramingView.constrainEdgesToSuperview(excluding: .vertical)
        backgroundImageFramingViewTopConstraint = backgroundImageFramingView.topAnchor.constraint(equalTo: topAnchor).isActive(true)

        addSubview(titleGradientView)
        titleGradientView.constrainEdges(to: backgroundImageFramingView, excluding: .top)

        addSubview(titleLabel)
        titleLabel.constrainEdges(to: backgroundImageFramingView, excluding: .vertical, withInsets: .horizontal(16))
        titleLabel.lastBaselineAnchor.constraint(equalTo: backgroundImageFramingView.bottomAnchor, constant: -16).isActive = true
        titleLabel.topAnchor.constraint(greaterThanOrEqualTo: backgroundImageFramingView.topAnchor).isActive = true
        titleGradientView.topAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -40).isActive = true

        addSubview(detailsView)
        detailsView.constrainEdges(to: layoutMarginsGuide, excluding: .vertical)
        detailsView.topAnchor.constraint(equalTo: backgroundImageFramingView.bottomAnchor, constant: 16).isActive = true

        addSubview(actionBarView)
        actionBarView.constrainEdges(to: layoutMarginsGuide, excluding: .top, withPriorities: .forCellSizing)
        actionBarView.topAnchor.constraint(equalTo: detailsView.bottomAnchor).isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateScrollBasedViews()
    }

    @available(*, unavailable)
    override func configure(gradientColor: UIColor, scrollAmountPublisher: AnyPublisher<CGFloat, Never>) {}

    func configure(
        with viewModel: ProminentBannerViewModel,
        scrollAmountPublisher: AnyPublisher<CGFloat, Never>,
        topInset: CGFloat,
        playButton: PlayButton
    ) {
        disposeBag = DisposeBag()

        super.configure(gradientColor: viewModel.accentColor.uiColor, scrollAmountPublisher: scrollAmountPublisher)

        backgroundImageView.configure(with: viewModel.backgroundImageURL)
        backgroundImageFramingViewTopConstraint?.constant = topInset

        titleLabel.attributedText = NSAttributedString(
            text: viewModel.title,
            font: .appFont(ofSize: 56, weight: .black),
            kerning: -2,
            lineHeight: 56
        )

        switch viewModel.details {
        case let .simple(details):
            detailsView.configure(details: details)
        case let .userAttributed(description, userAttribution, details):
            detailsView.configure(
                description: description,
                userAttribution: userAttribution,
                details: details
            )
        }

        actionBarView.configure(with: viewModel.actionBarViewModel, playButton: playButton)

        scrollAmountPublisher
            .sink { [weak self] scrollAmount in
                self?.scrollAmount = scrollAmount
                self?.updateScrollBasedViews()
            }
            .store(in: &disposeBag)
    }

    private func updateScrollBasedViews() {
        let bgEdgeExpansion = 20 * (1 - scrollAmount.pctInRange(0...150))

        backgroundImageContainerView.frame = backgroundImageFramingView.frame
        backgroundImageContainerView.frame.expand(left: bgEdgeExpansion, right: bgEdgeExpansion)
        backgroundImageContainerView.frame.origin.y = scrollAmount
        backgroundImageContainerView.frame.size.height = backgroundImageFramingView.frame.maxY - scrollAmount

        backgroundImageContainerView.alpha = 1 - scrollAmount.pctInRange(0...150)

        titleLabel.alpha = min(scrollAmount.pctInRange(-150 ... -50), 1 - scrollAmount.pctInRange(150...220))
        titleGradientView.alpha = min(titleLabel.alpha, backgroundImageContainerView.alpha)
    }
}

extension ProminentBannerView: TopBarVisibilityControllingViewProviding {

    var topBarVisibilityControllingView: UIView? {
        titleLabel
    }
}
