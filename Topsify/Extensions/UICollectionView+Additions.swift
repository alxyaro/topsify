// Created by Alex Yaro on 2023-08-06.

import Combine
import CombineCocoa
import UIKit

extension UICollectionView {

    var scrollAmountPublisher: AnyPublisher<CGFloat, Never> {
        didScrollPublisher
            .prepend(())
            .compactMap { [weak self] in
                guard let self else { return nil }
                return contentOffset.y + adjustedContentInset.top
            }
            .eraseToAnyPublisher()
    }
}

extension UICollectionReusableView {

    func useCollectionViewLayoutMargins() {
        preservesSuperviewLayoutMargins = true
        directionalLayoutMargins = .zero
        if let self = self as? UICollectionViewCell {
            self.contentView.preservesSuperviewLayoutMargins = true
            self.contentView.directionalLayoutMargins = .zero
        }
    }
}
