// Created by Alex Yaro on 2023-08-05.

import UIKit

final class BannerLayout: UICollectionViewCompositionalLayout {
    private var hideBanner = false

    private let bannerInvalidationContext: UICollectionViewLayoutInvalidationContext = {
        let context = UICollectionViewLayoutInvalidationContext()
        context.invalidateSupplementaryElements(ofKind: BannerView.kind, at: [BannerView.indexPath])
        return context
    }()

    override class var layoutAttributesClass: AnyClass {
        LayoutAttributes.self
    }

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
        invalidateLayout(with: bannerInvalidationContext)
        collectionView?.layoutIfNeeded()
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
        (bannerAttributes as? LayoutAttributes)?.topContentInset = topContentInset
    }
}

private extension UICollectionViewLayoutAttributes {

    var areForBanner: Bool {
        representedElementCategory == .supplementaryView &&
        representedElementKind == BannerView.kind
    }
}

extension BannerLayout {

    final class LayoutAttributes: UICollectionViewLayoutAttributes {

        var topContentInset: CGFloat = 0

        override func copy() -> Any {
            let copy = super.copy() as! Self
            copy.topContentInset = topContentInset
            return copy
        }

        override func isEqual(_ object: Any?) -> Bool {
            if let object = object as? Self {
                return super.isEqual(object) && topContentInset == object.topContentInset
            }
            return false
        }
    }
}
