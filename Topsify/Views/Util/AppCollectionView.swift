// Created by Alex Yaro on 2023-03-31.

import UIKit

class AppCollectionView: LayoutCallbackCollectionView {

    init(collectionViewLayout: UICollectionViewLayout) {
        super.init(frame: .zero, collectionViewLayout: collectionViewLayout)
        delaysContentTouches = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func touchesShouldCancel(in view: UIView) -> Bool {
        /// As per docs, by default this method returns false for `UIControl`s.
        /// We don't want that, so you can press down on a button and keep scrolling after, much like in real app.
        true
    }
}
