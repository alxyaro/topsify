// Created by Alex Yaro on 2023-02-26.

import UIKit

extension HomeViewController {
    final class CollectionManager: NSObject {
        private let navigationHeaderView: NavigationHeaderView
        private var sections = [HomeViewModel.Section]()

        init(navigationHeaderView: NavigationHeaderView) {
            self.navigationHeaderView = navigationHeaderView
        }

        private lazy var collectionViewLayout: UICollectionViewLayout = {
            let config = UICollectionViewCompositionalLayoutConfiguration()

            return UICollectionViewCompositionalLayout(
                sectionProvider: { [weak self] sectionIndex, _ in
                    guard let self, let section = sections[safe: sectionIndex] else {
                        return nil
                    }

                    let sectionLayout: NSCollectionLayoutSection
                    switch section {
                    case .navigationHeader:
                        sectionLayout = NavigationHeaderView.Cell.compositionalLayoutSection
                    case .recentActivity:
                        sectionLayout = Self.createRecentActivitySection()
                    case .generic, .moreLike:
                        sectionLayout = Self.createContentTileSection()
                    }

                    sectionLayout.contentInsets.leading = section.sideSpacing
                    sectionLayout.contentInsets.trailing = section.sideSpacing

                    if sectionIndex < sections.count-1 {
                        sectionLayout.contentInsets.bottom = section.spacingToNextSection
                    }

                    return sectionLayout
                },
                configuration: config
            )
        }()

        private(set) lazy var collectionView: UICollectionView = {
            let collectionView = AppCollectionView(collectionViewLayout: collectionViewLayout)

            collectionView.backgroundColor = .clear
            collectionView.dataSource = self
            collectionView.indicatorStyle = .white

            collectionView.registerEmptyCell()
            collectionView.registerEmptySupplementaryView(ofKind: UICollectionView.elementKindSectionHeader)
            collectionView.register(supplementaryViewType: HomeSimpleHeaderCell.self, ofKind: UICollectionView.elementKindSectionHeader)
            collectionView.register(supplementaryViewType: HomeArtistHeaderCell.self, ofKind: UICollectionView.elementKindSectionHeader)
            collectionView.register(cellType: NavigationHeaderView.Cell.self)
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
        case .navigationHeader:
            return 1
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
        case .navigationHeader:
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: NavigationHeaderView.Cell.self)
            cell.configure(with: navigationHeaderView)
            return cell
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
            return collectionView.dequeueEmptySupplementaryView(ofKind: kind, for: indexPath)
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
        case .navigationHeader, .recentActivity:
            return collectionView.dequeueEmptySupplementaryView(ofKind: kind, for: indexPath)
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

private extension HomeViewModel.Section {

    var sideSpacing: CGFloat {
        switch self {
        case .navigationHeader:
            return 0
        case .recentActivity, .generic, .moreLike:
            return 16
        }
    }

    var spacingToNextSection: CGFloat {
        switch self {
        case .navigationHeader:
            return 0
        case .recentActivity, .generic, .moreLike:
            return 24
        }
    }
}
