// Created by Alex Yaro on 2023-04-01.

import Reusable
import UIKit

final class PlayerStageView: AppCollectionView {
    typealias ItemIndex = Int
    typealias DataSource = UICollectionViewDiffableDataSource<Int, ItemIndex>
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Int, ItemIndex>

    struct TEMPItemModel {
        let artworkURL: URL
    }

    private let contentAreaLayoutGuide: UILayoutGuide

    private let layout: UICollectionViewCompositionalLayout = {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal

        return UICollectionViewCompositionalLayout(section: section, configuration: config)
    }()

    private lazy var diffableDataSource: DataSource = {
        .init(collectionView: self) { [weak self] collectionView, indexPath, itemIndex in
            guard let self, let item = self.items[safe: itemIndex] else {
                return collectionView.dequeueEmptyCell(for: indexPath)
            }
            let cell = collectionView.dequeueReusableCell(for: indexPath, cellType: PlayerStageBasicItemCell.self)
            cell.constrain(verticallyInside: self.contentAreaLayoutGuide)
            cell.configure(tempImageURL: item.artworkURL)
            return cell
        }
    }()

    private var items = FakeAlbums.sampleList.map(\.imageURL).map { TEMPItemModel(artworkURL: $0) }
    private var dataSourceSubsetStartIndex: ItemIndex = 0
    private var selectedItemIndex: ItemIndex = 0

    init(contentAreaLayoutGuide: UILayoutGuide) {
        self.contentAreaLayoutGuide = contentAreaLayoutGuide

        super.init(collectionViewLayout: layout)

        backgroundColor = .clear
        isPagingEnabled = true
        decelerationRate = .normal
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false

        delegate = self

        register(cellType: PlayerStageBasicItemCell.self)

        updateCollectionData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        contentAreaLayoutGuide.layoutFrame.contains(point)
    }

    private func pageIndex(for contentOffset: CGPoint) -> Int {
        Int(contentOffset.x / bounds.width)
    }

    private func updateCollectionData(snapToExactPage: Bool = true) {
        let previousItems = selectedItemIndex
        let nextItems = items.count - selectedItemIndex - 1

        let startIndex = selectedItemIndex - previousItems.clamped(max: 2)
        let endIndex = selectedItemIndex + nextItems.clamped(max: 2)

        let newData: [ItemIndex] = Array(startIndex...endIndex)

        if diffableDataSource.snapshot().itemIdentifiers == newData {
            // Current subset of indices matches what is expected, no need to update
            return
        }

        let previousTargetContentOffset = bounds.width * CGFloat(selectedItemIndex - dataSourceSubsetStartIndex)
        var offsetAdjustment: CGFloat = 0
        if !snapToExactPage {
            // This allows an update to the content offset to accomidate shifting cells without
            // it being perceivable to the user mid-drag.
            offsetAdjustment = contentOffset.x - previousTargetContentOffset
        }

        var snapshot = DataSourceSnapshot()
        snapshot.appendSections([0])
        snapshot.appendItems(newData)
        diffableDataSource.apply(snapshot, animatingDifferences: false)
        dataSourceSubsetStartIndex = newData[0]

        let targetContentOffset = bounds.width * CGFloat(selectedItemIndex - dataSourceSubsetStartIndex)
        setContentOffset(.init(x: targetContentOffset + offsetAdjustment, y: 0), animated: false)
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let result = super.hitTest(point, with: event)
        if result != nil {
            /// Using `setContentOffset` inside `scrollViewWillBeginDragging` does not seem to work, as it's overriden
            /// following the continued drag. As a result, calling `updateCollectionData`, which may potentially shift around the
            /// cells and require content offset changes, is problematic within that delegate method. Setting `contentOffset` directly
            /// seems to work better, but it's still buggy for certain edge cases (e.g. dragging near the end of the collection while removing
            /// the last cell). As a result, we need to update the collection data *before* the delegate method is called, and doing it
            /// here in `hitTest` seems to work well.
            updateCollectionData(snapToExactPage: false)
        }
        return result
    }
}

extension PlayerStageView: UICollectionViewDelegate {

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        /// Do not call anything here that tries to update `contentOffset` - see comment in `hitTest` above.
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocityPerMs: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        var targetIndex = dataSourceSubsetStartIndex + pageIndex(for: targetContentOffset.pointee)

        if targetIndex == selectedItemIndex && abs(velocityPerMs.x) > 0.5 {
            targetIndex += velocityPerMs.x > 0 ? 1 : -1
            targetIndex = targetIndex.clamped(to: 0...items.count-1)
        }

        selectedItemIndex = targetIndex
        targetContentOffset.pointee.x = CGFloat(selectedItemIndex - dataSourceSubsetStartIndex) * bounds.width
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            updateCollectionData()
        }
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateCollectionData()
    }
}
