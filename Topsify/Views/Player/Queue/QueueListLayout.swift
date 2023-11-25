// Created by Alex Yaro on 2023-07-15.

import UIKit

final class QueueListLayout: UICollectionViewCompositionalLayout {
    static let topEmptySpacerViewKind = "EmptySpacer"

    private static let queueSectionIndex = QueueListView.Section.nextInQueue.index
    private static let upNextSectionIndex = QueueListView.Section.nextFromSource.index

    private class CollectionState {
        var emptySectionIndices = Set<Int>()
    }

    private let collectionState: CollectionState

    init() {
        let collectionState = CollectionState()
        self.collectionState = collectionState
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

                let headerHeight = QueueListHeaderView.computePreferredHeight()
                let headerSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(headerHeight)
                )
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: headerSize,
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                header.pinToVisibleBounds = true

                let isSectionEmpty = collectionState.emptySectionIndices.contains(sectionIndex)

                if !isSectionEmpty {
                    section.boundarySupplementaryItems = [header]
                    section.contentInsets.top = 0
                    section.contentInsets.bottom = sectionIndex < Self.upNextSectionIndex ? 20 : 0
                } else {
                    if sectionIndex == Self.queueSectionIndex {
                        /// Give the queue section a little bit of extra height when empty, as to make the interactive move into this
                        /// empty section a little easier (the drag will be easier to control and more predictable).
                        section.contentInsets.bottom = 24
                    }
                }

                /// If we're at the first section, we want to prepend some extra spacing, much like you see in the real app.
                /// Since the compositional layout doesn't support adding spacing above sections, an empty supplementary
                /// view is used as a nifty workaround. The alternative would be an empty section, which is not as elegant.
                /// The real app likely uses a UITableView (or a compositional list layout) to get that extra spacing by default.
                if sectionIndex == 0 {
                    let spacerSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        /// Unfortunately, supplementary items are simply overlaid by compositional layout, not vertically stacked.
                        /// Therefore, we need to also add the height of the actual header, which will hover above the spacer.
                        heightDimension: .absolute(headerHeight + 20)
                    )
                    let spacer = NSCollectionLayoutBoundarySupplementaryItem(
                        layoutSize: spacerSize,
                        elementKind: Self.topEmptySpacerViewKind,
                        alignment: .top
                    )
                    section.boundarySupplementaryItems.insert(spacer, at: 0)
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

        collectionState.emptySectionIndices = .init()

        if let collectionView {
            for sectionIndex in 0..<collectionView.numberOfSections {
                let sectionIsEmpty = collectionView.numberOfItems(inSection: sectionIndex) == 0
                let movingItemIntoSection = (context.targetIndexPathsForInteractivelyMovingItems ?? []).contains { $0.section == sectionIndex }
                if sectionIsEmpty && !movingItemIntoSection {
                    collectionState.emptySectionIndices.insert(sectionIndex)
                }
            }
        }

        super.invalidateLayout(with: context)
    }

    override func targetIndexPath(forInteractivelyMovingItem currentIndexPath: IndexPath, withPosition position: CGPoint) -> IndexPath {
        /// For some reason, if you drag your finger far left and try moving up and down, the layout will fail to
        /// find a new IndexPath. Setting a fixed x position prevents that.
        var position = position
        position.x = 0
        let targetIndexPath = super.targetIndexPath(forInteractivelyMovingItem: currentIndexPath, withPosition: position)

        var upNextSectionBoundaryPosition: CGFloat?
        if let firstItemInUpNextSectionAttributes = layoutAttributesForItem(at: IndexPath(item: 0, section: Self.upNextSectionIndex)) {
            upNextSectionBoundaryPosition = firstItemInUpNextSectionAttributes.frame.minY - 20
        }
        let attributesForTargetIndexPath = layoutAttributesForItem(at: targetIndexPath)

        // The code below enables easy and precise dragging between the
        // queue & upNext sections, even if there are no items in either of them.

        func shouldMoveToUpNextSection() -> Bool {
            if let upNextSectionBoundaryPosition,
               position.y > upNextSectionBoundaryPosition
            { return true }

            if
                collectionView?.numberOfItems(inSection: Self.queueSectionIndex) == 1,
                targetIndexPath == IndexPath(item: 0, section: Self.queueSectionIndex),
                let attributesForTargetIndexPath,
                position.y - attributesForTargetIndexPath.frame.midY >= 15
            { return true }

            return false
        }

        func shouldMoveToQueueSection() -> Bool {
            if let upNextSectionBoundaryPosition,
               position.y < upNextSectionBoundaryPosition
            { return true}

            if
                collectionView?.numberOfItems(inSection: Self.queueSectionIndex) == 0,
                targetIndexPath == IndexPath(item: 0, section: Self.upNextSectionIndex),
                let attributesForTargetIndexPath,
                attributesForTargetIndexPath.frame.midY - position.y >= 15
            { return true }

            return false
        }

        if currentIndexPath.section < Self.upNextSectionIndex && targetIndexPath.section < Self.upNextSectionIndex && shouldMoveToUpNextSection() {
            return IndexPath(item: 0, section: Self.upNextSectionIndex)
        }
        /// The `currentIndexPath` check is very important here; the item may already be in the queue section, and if we assume its not
        /// and try to move it there again, the `numberOfItems` call will include the moving item, and so we'll get an off-by-one index error.
        if currentIndexPath.section > Self.queueSectionIndex && targetIndexPath.section > Self.queueSectionIndex && shouldMoveToQueueSection() {
            return IndexPath(item: collectionView?.numberOfItems(inSection: Self.queueSectionIndex) ?? 0, section: Self.queueSectionIndex)
        }

        return targetIndexPath
    }

    override func layoutAttributesForInteractivelyMovingItem(at indexPath: IndexPath, withTargetPosition position: CGPoint) -> UICollectionViewLayoutAttributes {
        let attrs = super.layoutAttributesForInteractivelyMovingItem(at: indexPath, withTargetPosition: position)
        /// Set the x position to the natural leading edge of cells, so that the cell being is fixed along the horizontal axis.
        /// (This is the same behaviour you get in UITableViews or with the UICollectionLayoutListConfiguration)
        attrs.frame.origin.x = 0
        return attrs
    }
}
