// Created by Alex Yaro on 2023-03-01.

import Reusable
import UIKit

final class HomeArtistHeaderCell: UICollectionReusableView, Reusable {

    private let imageView: RemoteImageView = {
        let imageView = RemoteImageView()
        imageView.contentMode = .scaleAspectFill
        let size: CGFloat = 40
        imageView.widthAnchor.constraint(equalToConstant: size).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: size).isActive = true
        imageView.layer.cornerRadius = size / 2
        imageView.clipsToBounds = true
        return imageView
    }()

    private let captionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextSecondary
        label.font = .appFont(ofSize: 11, weight: .regular)
        label.numberOfLines = 1
        return label
    }()

    private let artistLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 21, weight: .bold)
        label.numberOfLines = 1
        return label
    }()

    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [captionLabel, artistLabel])
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.spacing = 0
        return stackView
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, textStackView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 12
        return stackView
    }()

    private lazy var containerButton = AppButton(contentView: mainStackView, scaleOnTap: false)

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(containerButton)
        containerButton.constrainEdgesToSuperview(excluding: .trailing, withInsets: .bottom(16), withPriorities: .forCellSizing)
        containerButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: HomeViewModel.ArtistHeaderViewModel) {
        imageView.configure(with: viewModel.avatarURL)
        captionLabel.text = viewModel.captionText
        artistLabel.text = viewModel.artistName
    }
}
