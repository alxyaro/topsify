// Created by Alex Yaro on 2023-08-30.

import Combine
import UIKit

protocol TopBarConfiguring: AnyObject {
    var topBarTitlePublisher: AnyPublisher<String?, Never> { get }
    var topBarAccentColorPublisher: AnyPublisher<UIColor?, Never> { get }
    var topBarPlayButton: PlayButton? { get }
    var topBarVisibility: TopBarVisibility { get }
    var topBarButtonStyle: TopBarButtonStyle? { get }
    var topBarScrollAmountPublisher: AnyPublisher<CGFloat, Never> { get }
}

enum TopBarButtonStyle {
    /// When the bar is transparent, the buttons get a translucent background to give them more contrast.
    case prominent
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
    /// The banner view type must conform to `TopBarVisibilityControllingViewProviding` for this to work.
    static func controlledByBanner(in collectionView: LayoutCallbackCollectionView) -> Self {
        let viewPublisher = collectionView.didLayoutSubviewsPublisher
            .map { () -> UIView? in
                guard let banner = collectionView.bannerView() else { return nil }

                /// The view returned should always have an accurate frame (have been laid out before).
                /// UIKit doesn't seem to layout supplementary views as part of the UICollectionView's `layoutSubviews`
                /// invocation (despite setting the view's frame), so we perform a manual layout here if necessary.
                banner.layoutIfNeeded()

                return (banner as? TopBarVisibilityControllingViewProviding)?.topBarVisibilityControllingView
            }
            .eraseToAnyPublisher()
        return .controlledByView(viewPublisher)
    }
}
