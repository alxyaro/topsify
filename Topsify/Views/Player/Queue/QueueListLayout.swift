// Created by Alex Yaro on 2023-07-15.

import UIKit

final class QueueListLayout: UICollectionViewCompositionalLayout {
    private static let queueSectionIndex = 1
    private static let upNextSectionIndex = 2

    private class LayoutState {
        var isQueueSectionActive: Bool = false
    }

    private let layoutState: LayoutState

    init() {
        let layoutState = LayoutState()
        self.layoutState = layoutState
        super.init(
            sectionProvider: { sectionIndex, layoutEnvironment in

                let size = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    /// Unfortunately, self-sizing doesn't work when you're interactively dragging/moving cells between sections.
                    /// The cell that's being moved has its height set to the estimated height, and it stays that way until the move
                    /// concludes. The movement of the others cells is also glitchy with them switching back and fourth between
                    /// positions. To avoid these strange issues, an absolute height is used (this is also the reason why a list
                    /// configuation section is not used either, as that uses an estimated cell height of 44 internally).
                    heightDimension: .absolute(SongListCell.computePreferredHeight())
                )
                let item = NSCollectionLayoutItem(layoutSize: size)
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
                let section = NSCollectionLayoutSection(group: group)

                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40)),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                header.pinToVisibleBounds = true

                let hideSection = sectionIndex == Self.queueSectionIndex && !layoutState.isQueueSectionActive

                if hideSection {
                    section.contentInsets.bottom = 16
                } else {
                    section.boundarySupplementaryItems = [header]
                    section.contentInsets.top = 0
                    section.contentInsets.bottom = 24
                }

                return section
            },
            configuration: .init()
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {

        if let collectionView, collectionView.numberOfSections >= Self.upNextSectionIndex {
            let movingIntoQueueSection = (context.targetIndexPathsForInteractivelyMovingItems ?? []).contains { $0.section == Self.queueSectionIndex }
            let queueSectionHasItems = collectionView.numberOfItems(inSection: Self.queueSectionIndex) > 0

            layoutState.isQueueSectionActive = queueSectionHasItems || movingIntoQueueSection
        }

        super.invalidateLayout(with: context)
    }

    override func targetIndexPath(forInteractivelyMovingItem previousIndexPath: IndexPath, withPosition position: CGPoint) -> IndexPath {
        /// For some reason, if you drag your finger far left and try moving up and down, the layout will fail to
        /// find a new IndexPath. Setting the x position to zero prevents that.
        var position = position
        position.x = 0
        let targetIndexPath = super.targetIndexPath(forInteractivelyMovingItem: previousIndexPath, withPosition: position)

        let upNextSectionHeaderAttributes = layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: .init(item: 0, section: Self.upNextSectionIndex))
        let attributesForMovingItem = layoutAttributesForItem(at: targetIndexPath)

        // The code below enables easy and precise dragging between the
        // queue & upNext sections, even if there are no items in either of them.

        func shouldMoveToUpNextSection() -> Bool {
            if let upNextSectionHeaderAttributes,
               position.y > upNextSectionHeaderAttributes.frame.minY
            { return true }

            if
                collectionView?.numberOfItems(inSection: Self.queueSectionIndex) == 1,
                targetIndexPath == IndexPath(item: 0, section: Self.queueSectionIndex),
                let attributesForMovingItem,
                position.y - attributesForMovingItem.frame.midY >= 15
            { return true }

            return false
        }

        func shouldMoveToQueueSection() -> Bool {
            if let upNextSectionHeaderAttributes,
               position.y < upNextSectionHeaderAttributes.frame.maxY
            { return true}

            if
                collectionView?.numberOfItems(inSection: Self.queueSectionIndex) == 0,
                targetIndexPath == IndexPath(item: 0, section: Self.upNextSectionIndex),
                let attributesForMovingItem,
                attributesForMovingItem.frame.midY - position.y >= 15
            { return true }

            return false
        }

        if targetIndexPath.section < Self.upNextSectionIndex && shouldMoveToUpNextSection() {
            return IndexPath(item: 0, section: Self.upNextSectionIndex)
        }
        if targetIndexPath.section > Self.queueSectionIndex && shouldMoveToQueueSection() {
            return IndexPath(item: collectionView?.numberOfItems(inSection: Self.queueSectionIndex) ?? 0, section: Self.queueSectionIndex)
        }

        return targetIndexPath
    }

    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attrs = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        /// Set the x position to zero, so that the cell being moved aligns with the bounds of the content.
        /// (This is the same behaviour you get in UITableViews or with the UICollectionLayoutListConfiguration)
        attrs.frame.origin.x = 0
        return attrs
    }
}
