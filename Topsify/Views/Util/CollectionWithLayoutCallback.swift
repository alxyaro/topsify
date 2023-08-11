// Created by Alex Yaro on 2023-08-10.

import Combine
import UIKit

/// A simple subclass of `UICollectionView` that lets you observe when a layout pass has completed.
///
/// This enables you to grab subviews within the collection view as soon as they've had their frames calculated.
/// See: https://stackoverflow.com/questions/14020027/how-do-i-know-that-the-uicollectionview-has-been-loaded-completely
class CollectionWithLayoutCallback: UICollectionView {

    var didLayoutSubviewsPublisher: AnyPublisher<Void, Never> {
        didLayoutSubviewsSubject.eraseToAnyPublisher()
    }

    private let didLayoutSubviewsSubject = PassthroughSubject<Void, Never>()

    override func layoutSubviews() {
        super.layoutSubviews()
        didLayoutSubviewsSubject.send()
    }
}
