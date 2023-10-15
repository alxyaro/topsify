// Created by Alex Yaro on 2023-08-05.

import UIKit

final class BannerLayout: UICollectionViewCompositionalLayout {
    private var bannerHeight: CGFloat = 0
    private var hideBanner = false

    private let bannerInvalidationContext: UICollectionViewLayoutInvalidationContext = {
        let context = UICollectionViewLayoutInvalidationContext()
        context.invalidateSupplementaryElements(ofKind: BannerView.kind, at: [BannerView.indexPath])
        return context
    }()

    convenience override init(
        section: NSCollectionLayoutSection,
        configuration: UICollectionViewCompositionalLayoutConfiguration = .init()
    ) {
        self.init(sectionProvider: { _, _ in section }, configuration: configuration)
    }

    override init(
        sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider,
        configuration: UICollectionViewCompositionalLayoutConfiguration = .init()
    ) {
        let bannerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .estimated(200)
        )
        let banner = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: bannerSize,
            elementKind: BannerView.kind,
            alignment: .top
        )

        configuration.boundarySupplementaryItems.insert(banner, at: 0)

        super.init(
            sectionProvider: sectionProvider,
            configuration: configuration
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadBanner() {
        /// By removing and then re-added the banner attributes, the collection view will ask its data source for a new banner view to be provided.
        for hideBanner in [true, false] {
            self.hideBanner = hideBanner
            invalidateLayout(with: bannerInvalidationContext)
            collectionView?.layoutIfNeeded()
        }
    }

    func reloadBannerSize() {

        /// This is a necessary step, leveraging the quirk noted in the observation comment below.
        /// By resetting the height (i.e. reducing it), `UICollectionView` will prompty notice that the height of the `UICollectionViewLayoutAttributes`
        /// for the banner is now smaller than the last recorded preferred height, so it will invalidate the perferred height and call into `shouldInvalidateLayout`
        /// again.
        ///
        /// Without this, if the size of the banner hasn't changed when this is called, the `shouldInvalidateLayout` method won't get called by
        /// `UICollectionView`, so the layout gets glitched and the height of the banner is set to the estimated height defined above in the initalizer.
        ///
        bannerHeight = 0

        invalidateLayout(with: bannerInvalidationContext)
        collectionView?.layoutIfNeeded()
    }

    override func shouldInvalidateLayout(
        forPreferredLayoutAttributes preferredAttributes: UICollectionViewLayoutAttributes,
        withOriginalAttributes originalAttributes: UICollectionViewLayoutAttributes
    ) -> Bool {
        if preferredAttributes.areForBanner {

            /// ### Important observation on how the compositional layout treats preferred sizing:
            ///
            /// UICollectionView calls this method after the initial call to `layoutAttributesForElements(in)`, if the cell has different size preference
            /// than what was returned. The compositional layout essentially never returns `true` in the super impl of this method, but if the preferred size is
            /// different, it is updated internally (size of the attributes instance). Then, even though the method returns `false`, the collection view calls some
            /// internal method on the compositional layout (which you can see by breakpointing on `invalidateLayout(with:)`), causing it to
            /// invalidate the layout and result in another call to `layoutAttributesForElements(in)`.
            ///
            /// The interesting part is how UICollectionView decides whether or not to compute the preferred size again & re-call this method
            /// (`shouldInvalidateLayout`). If `layoutAttributesForElements(in)` returns a size for a cell that's *greater or equal* to the
            /// preferred size given previously, it will not invoke this method again, thus terminating any layout loop. However, if the size is *smaller*, this
            /// method **is called again, causing an infinite loop if the returned size in `layoutAttributesForElements(in)` continues to be smaller
            /// than the preferred!!!**
            ///
            /// So the takeaway is: whatever the size of `preferredAttributes`, make sure the size returned in
            /// `layoutAttributesForElements(in)` for the corresponding element is never smaller.
            ///
            /// The infinute loop can be easily reproduced by adding the following line right after this documentation:
            /// `preferredAttributes.size.height -= 1`

            bannerHeight = preferredAttributes.size.height
            let topContentInset = collectionView?.adjustedContentInset.top ?? 0
            preferredAttributes.frame.origin.y = -topContentInset
            preferredAttributes.size.height -= topContentInset
        }
        return super.shouldInvalidateLayout(forPreferredLayoutAttributes: preferredAttributes, withOriginalAttributes: originalAttributes)
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = super.layoutAttributesForElements(in: rect)
        if hideBanner {
            attributes = attributes?.filter { !$0.areForBanner }
        } else if let bannerAttributes = attributes?.first(where: { $0.areForBanner }) {
            adjustBannerAttributes(bannerAttributes)
        }
        return attributes
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        if let attributes, attributes.areForBanner {
            if hideBanner { return nil }
            adjustBannerAttributes(attributes)
        }
        return attributes
    }

    private func adjustBannerAttributes(_ bannerAttributes: UICollectionViewLayoutAttributes) {
        guard let collectionView else { return }

        let topContentInset = collectionView.adjustedContentInset.top

        bannerAttributes.size.height = bannerHeight
        bannerAttributes.frame.origin.y = -topContentInset
    }
}

private extension UICollectionViewLayoutAttributes {

    var areForBanner: Bool {
        representedElementCategory == .supplementaryView &&
        representedElementKind == BannerView.kind
    }
}
