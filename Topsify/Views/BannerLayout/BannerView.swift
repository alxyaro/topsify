// Created by Alex Yaro on 2023-08-05.

import Reusable
import UIKit

class BannerView: UICollectionReusableView, Reusable {
    static let kind = "BannerView"

    required override init(frame: CGRect) {
        super.init(frame: frame)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    final override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        super.preferredLayoutAttributesFitting(layoutAttributes)
    }
}

extension UICollectionView {

    func registerBannerViewType(_ type: BannerView.Type) {
        register(supplementaryViewType: type, ofKind: BannerView.kind)
    }

    func dequeueBannerView<BV: BannerView>(type: BV.Type = BV.self) -> BV {
        dequeueReusableSupplementaryView(ofKind: BannerView.kind, for: IndexPath(item: 0, section: 0), viewType: type)
    }
}
