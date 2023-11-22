// Created by Alex Yaro on 2023-11-05.

import Reusable
import UIKit

final class AlbumRowCell: UICollectionViewCell, Reusable {

    private let imageView: RemoteImageView = {
        let imageView = RemoteImageView()
        imageView.constrainDimensions(uniform: 80)
        imageView.requireIntrinsicWidth()
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 17, weight: .bold)
        label.textColor = .appTextPrimary
        label.numberOfLines = 1
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 13)
        label.textColor = .appTextSecondary
        label.numberOfLines = 1
        return label
    }()

    private let button: AppButton

    private var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        
        let labelsStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        labelsStackView.axis = .vertical
        labelsStackView.spacing = 0

        let mainStackView = UIStackView(arrangedSubviews: [imageView, labelsStackView])
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.spacing = 12

        button = AppButton(contentView: mainStackView, scaleOnTap: false)

        super.init(frame: .zero)

        contentView.addSubview(button)
        button.constrainEdges(to: contentView.layoutMarginsGuide)

        useCollectionViewLayoutMargins()
        directionalLayoutMargins = .vertical(8)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: AlbumRowViewModel) {
        disposeBag = .init()

        imageView.configure(with: viewModel.imageURL)
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle

        button.tapPublisher
            .sink(receiveValue: viewModel.onTap)
            .store(in: &disposeBag)
    }

    static func compositionalLayoutSection() -> NSCollectionLayoutSection {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        return section
    }
}
