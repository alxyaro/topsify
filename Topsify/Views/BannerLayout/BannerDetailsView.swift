// Created by Alex Yaro on 2023-10-04.

import UIKit

final class BannerDetailsView: UIView {

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

    private lazy var artistRowStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [artistAvatarImageView, artistsLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
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

        let stackView = UIStackView(arrangedSubviews: [titleLabel, artistRowStackView, detailsLabel])
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

    func configure(title: String?, artistInfo: ArtistInfo?, details: String) {
        titleLabel.text = title
        titleLabel.isHidden = title == nil

        if let artistInfo {
            artistsLabel.text = artistInfo.name
            artistAvatarImageView.configure(with: artistInfo.avatarURL)
        }
        artistRowStackView.isHidden = artistInfo == nil

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
