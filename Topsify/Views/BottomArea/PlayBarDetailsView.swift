// Created by Alex Yaro on 2023-06-19.

import Reusable
import UIKit

final class PlayBarDetailsView: UIView {

    private let collectionViewLayout: UICollectionViewLayout = {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal

        return UICollectionViewCompositionalLayout(section: section, configuration: config)
    }()

    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.dataSource = self
        collectionView.register(cellType: PlayBarDetailsCell.self)
        return collectionView
    }()

    init() {
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        addSubview(collectionView)
        collectionView.constrainEdgesToSuperview()
    }
}

extension PlayBarDetailsView: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        3
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PlayBarDetailsCell.self)
        cell.configure(with: ())
        return cell
    }
}

private final class PlayBarDetailsCell: UICollectionViewCell, Reusable {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 13)
        label.textColor = .appTextPrimary
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 13)
        label.textColor = .appTextSecondary
        return label
    }()

    private lazy var marqueeTitleLabel = MarqueeView(titleLabel, gradientSize: 8)
    private lazy var marqueeSubtitleLabel = MarqueeView(subtitleLabel, gradientSize: 8)

    override init(frame: CGRect) {
        super.init(frame: frame)

        let stackView = UIStackView(arrangedSubviews: [marqueeTitleLabel, marqueeSubtitleLabel])
        stackView.axis = .vertical
        stackView.spacing = 2

        addSubview(stackView)
        stackView.constrainEdgesToSuperview(excluding: .vertical, withInsets: .init(horizontal: 10, vertical: 0))
        stackView.constrainInCenterOfSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with: Void /* TODO: impl */) {
        titleLabel.text = "This is some temp sample text"
        subtitleLabel.text = "Metro Boomin"
        marqueeTitleLabel.reset()
        marqueeSubtitleLabel.reset()
    }
}
