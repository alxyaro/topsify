// Created by Alex Yaro on 2023-08-07.

import Combine
import UIKit

protocol NavBarConfiguring {
    // var navBarTitlePublisher: AnyPublisher<String, Never> { get }
    var navBarAccentColor: UIColor { get }
    var navBarPlayButton: PlayButton? { get }
    /// If provided, the nav bar remains hidden while the view is relatively positioned below the nav bar.
    /// Once the view reaches the nav bar & goes underneath it, the nav bar turns fully opaque.
    var navBarVisibilityManagingView: UIView? { get }
    var navBarVisibilityManagingViewMovedPublisher: AnyPublisher<Void, Never> { get }
}

extension NavBarConfiguring {
    var navBarVisibilityManagingView: UIView? { nil }
    var navBarVisibilityManagingViewMovedPublisher: AnyPublisher<Void, Never> { .never() }
}
