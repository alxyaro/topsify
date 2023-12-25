// Created by Alex Yaro on 2023-10-04.

import UIKit

final class BannerDetailsView: UIView {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.numberOfLines = 1
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextSecondary
        label.font = .appFont(ofSize: 13)
        label.numberOfLines = 1
        return label
    }()

    private let attributionContainerView: UIView = {
        let view = UIView()
        return view
    }()

    private let detailsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextSecondary
        label.font = .appFont(ofSize: 13)
        label.numberOfLines = 1
        return label
    }()

    init() {
        super.init(frame: .zero)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, descriptionLabel, attributionContainerView, detailsLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 8
        stackView.setCustomSpacing(4, after: titleLabel)

        addSubview(stackView)
        stackView.constrainEdgesToSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(
        title: String? = nil,
        description: String? = nil,
        attributionViewModel: BannerAttributionViewModel? = nil,
        details: String
    ) {
        titleLabel.attributedText = NSAttributedString(text: title, font: .appFont(ofSize: 24, weight: .bold), kerning: -1)
        titleLabel.isHidden = title == nil

        descriptionLabel.text = description
        descriptionLabel.isHidden = description == nil

        attributionContainerView.subviews.forEach { $0.removeFromSuperview() }
        if let attributionViewModel {
            attributionContainerView.isHidden = false
            let attributionView = BannerAttributionView(viewModel: attributionViewModel)
            attributionContainerView.addSubview(attributionView)
            attributionView.constrainEdgesToSuperview()
        } else {
            attributionContainerView.isHidden = true
        }

        detailsLabel.text = details
    }
}

extension BannerDetailsView: TopBarVisibilityControllingViewProviding {

    var topBarVisibilityControllingView: UIView? {
        titleLabel
    }
}

extension BannerDetailsView {

    struct ArtistInfo {
        let avatarURL: URL
        let name: String
    }
}
