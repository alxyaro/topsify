// Created by Alex Yaro on 2023-08-30.

import Combine
import UIKit

protocol TopBarConfiguring {
    var topBarTitlePublisher: AnyPublisher<String?, Never> { get }
    var topBarAccentColorPublisher: AnyPublisher<UIColor?, Never> { get }
    var topBarPlayButton: PlayButton? { get }
    var topBarVisibility: TopBarVisibility { get }
}

enum TopBarVisibility {
    /// The top bar is always visible
    case alwaysVisible
    /// The top bar visibility is controlled by the given view.
    /// As the position of the view meets and goes above the top bar, the top bar fades in.
    /// The visibility status is updated whenever the publisher emits.
    case controlledByView(AnyPublisher<UIView?, Never>)

    /// A convinence creator of `controlledByView` for bannered collection view VCs.
    /// The banner of the collection view will provide the subview that controls the top bar visibility.
    static func controlledByBannerInCollectionView<BV: BannerView & TopBarVisibilityControllingViewProviding>(
        _ collectionView: LayoutCallbackCollectionView,
        bannerType: BV.Type
    ) -> Self {
        let viewPublisher = collectionView.didLayoutSubviewsPublisher
            .map { () -> UIView? in
                guard let banner = collectionView.bannerView(type: bannerType) else { return nil }

                /// The view returned should always have an accurate frame (have been laid out before).
                /// UIKit doesn't seem to layout supplementary views as part of the UICollectionView's `layoutSubviews`
                /// invocation (despite setting the view's frame), so we perform a manual layout here if necessary.
                banner.layoutIfNeeded()

                return banner.topBarVisibilityControllingView
            }
            .eraseToAnyPublisher()
        return .controlledByView(viewPublisher)
    }
}
