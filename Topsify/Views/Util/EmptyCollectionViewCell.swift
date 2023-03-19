// Created by Alex Yaro on 2023-02-26.

import UIKit

class EmptyCollectionViewCell: UICollectionViewCell {
    static let registration = UICollectionView.CellRegistration<EmptyCollectionViewCell, Void> { _, _, _ in }
}

extension UICollectionView {
    func dequeueEmptyCell(for indexPath: IndexPath) -> UICollectionViewCell {
        dequeueConfiguredReusableCell(using: EmptyCollectionViewCell.registration, for: indexPath, item: ())
    }
}
