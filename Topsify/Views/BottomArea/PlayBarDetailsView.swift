// Created by Alex Yaro on 2023-06-19.

import Combine
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
        collectionView.delegate = self
        collectionView.registerEmptyCell()
        collectionView.register(cellType: PlayBarDetailsCell.self)
        return collectionView
    }()

    private var lastWidth: CGFloat = 0
    private var itemList: PlayBarViewModel.ItemList?
    private let selectedIndexSubject = PassthroughSubject<Int, Never>()

    private var currentItemIndex: Int {
        Int(round(collectionView.contentOffset.x / bounds.width))
    }

    var selectedIndexPublisher: AnyPublisher<Int, Never> {
        selectedIndexSubject.eraseToAnyPublisher()
    }

    init() {
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if lastWidth != bounds.width {
            updateContentOffset()
        }
        lastWidth = bounds.width
    }

    private func setUpView() {
        addSubview(collectionView)
        collectionView.constrainEdgesToSuperview()
    }

    private func updateContentOffset() {
        let activeIndex = itemList?.activeIndex ?? 0
        collectionView.contentOffset.x = CGFloat(activeIndex) * bounds.width
    }

    func updateItemList(_ itemList: PlayBarViewModel.ItemList) {
        self.itemList = itemList
        collectionView.reloadData()
        updateContentOffset()
    }
}

extension PlayBarDetailsView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        itemList?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = itemList?[indexPath.item] else {
            return collectionView.dequeueEmptyCell(for: indexPath)
        }
        let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PlayBarDetailsCell.self)
        cell.configure(with: item)
        return cell
    }
}

extension PlayBarDetailsView: UICollectionViewDelegate {

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            selectedIndexSubject.send(currentItemIndex)
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        /// `scrollViewDidEndDecelerating` seems to be fired if the collection view is bouncing back
        /// (outside the content rectangle) and the user touches down before the bounce back is complete.
        /// As such, we ignore the event if `isTracking` is `true`.
        guard !scrollView.isTracking else { return }

        selectedIndexSubject.send(currentItemIndex)
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

    func configure(with item: PlayBarViewModel.Item) {
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        marqueeTitleLabel.reset()
        marqueeSubtitleLabel.reset()
    }
}
