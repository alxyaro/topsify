// Created by Alex Yaro on 2023-08-06.

import Combine
import UIKit

extension UICollectionView {

    var scrollDownAmountPublisher: AnyPublisher<CGFloat, Never> {
        didScrollPublisher
            .prepend(())
            .compactMap { [weak self] in
                guard let self else { return nil }
                return contentOffset.y + adjustedContentInset.top
            }
            .eraseToAnyPublisher()
    }
}
