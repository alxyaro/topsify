// Created by Alex Yaro on 2023-02-26.

import UIKit

extension HomeViewController {
    final class CollectionManager: NSObject {
        private static let sideSpacing: CGFloat = 16

        private var sections = [HomeViewModel.Section]()

        private lazy var collectionViewLayout: UICollectionViewLayout = {
            let config = UICollectionViewCompositionalLayoutConfiguration()
            config.interSectionSpacing = 24

            return UICollectionViewCompositionalLayout(sectionProvider: { [weak self] sectionIndex, _ in
                guard let section = self?.sections[safe: sectionIndex] else {
                    return nil
                }

                let sectionLayout: NSCollectionLayoutSection
                switch section {
                case .recentActivity:
                    sectionLayout = Self.createRecentActivitySection()
                case .generic, .moreLike:
                    sectionLayout = Self.createContentTileSection()
                }

                sectionLayout.contentInsets.leading = Self.sideSpacing
                sectionLayout.contentInsets.trailing = Self.sideSpacing

                return sectionLayout
            }, configuration: config)
        }()

        private(set) lazy var collectionView: UICollectionView = {
            let collectionView = AppCollectionView(collectionViewLayout: collectionViewLayout)

            collectionView.backgroundColor = .clear
            collectionView.dataSource = self

            collectionView.register(supplementaryViewType: HomeSimpleHeaderCell.self, ofKind: UICollectionView.elementKindSectionHeader)
            collectionView.register(supplementaryViewType: HomeArtistHeaderCell.self, ofKind: UICollectionView.elementKindSectionHeader)
            collectionView.register(cellType: ContentTileCell.self)
            collectionView.register(cellType: RecentActivityItemCell.self)

            return collectionView
        }()

        func updateSections(_ sections: [HomeViewModel.Section]) {
            self.sections = sections
            collectionView.reloadData()
        }
    }
}

// MARK: - Section Builders

private extension HomeViewController.CollectionManager {

    static func createRecentActivitySection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.5),
            heightDimension: .absolute(RecentActivityItemCell.height)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(RecentActivityItemCell.height)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8

        return section
    }

    static func createContentTileSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .absolute(ContentTileCell.defaultFixedWidth),
            heightDimension: .estimated(ContentTileCell.estimatedHeight)
        )

        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: itemSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 16
        section.boundarySupplementaryItems = [.header()]

        return section
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController.CollectionManager: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = sections[safe: section] else {
            return 0
        }
        switch section {
        case let .generic(_, contentTiles), let .moreLike(_, contentTiles):
            return contentTiles.count
        case let .recentActivity(viewModels):
            return viewModels.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = sections[safe: indexPath.section] else {
            return collectionView.dequeueEmptyCell(for: indexPath)
        }
        switch section {
        case let .generic(_, contentTiles), let .moreLike(_, contentTiles):
            guard let viewModel = contentTiles[safe: indexPath.item] else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: ContentTileCell.self)
            cell.configure(with: viewModel)
            return cell
        case let .recentActivity(viewModels):
            guard let viewModel = viewModels[safe: indexPath.item] else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: RecentActivityItemCell.self)
            cell.configure(with: viewModel)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let section = sections[safe: indexPath.section] else {
            return collectionView.dequeueEmptyCell(for: indexPath)
        }
        switch section {
        case let .generic(title, _):
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath, viewType: HomeSimpleHeaderCell.self)
            cell.configure(heading: title)
            return cell
        case let .moreLike(headerViewModel, _):
            let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, for: indexPath, viewType: HomeArtistHeaderCell.self)
            cell.configure(with: headerViewModel)
            return cell
        case .recentActivity:
            return collectionView.dequeueEmptyCell(for: indexPath)
        }
    }
}

private extension NSCollectionLayoutBoundarySupplementaryItem {
    static func header(estimatedHeight: CGFloat = 50) -> Self {
        .init(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(estimatedHeight)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}
