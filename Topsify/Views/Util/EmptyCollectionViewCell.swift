// Created by Alex Yaro on 2023-02-26.

import Reusable
import UIKit

class EmptyCollectionViewCell: UICollectionViewCell, Reusable {}

extension UICollectionView {

    func registerEmptyCell() {
        register(cellType: EmptyCollectionViewCell.self)
    }

    func registerEmptySupplementaryView(ofKind kind: String) {
        register(supplementaryViewType: EmptyCollectionViewCell.self, ofKind: kind)
    }

    func dequeueEmptyCell(for indexPath: IndexPath) -> EmptyCollectionViewCell {
        dequeueReusableCell(for: indexPath)
    }

    func dequeueEmptySupplementaryView(ofKind kind: String, for indexPath: IndexPath) -> EmptyCollectionViewCell {
        dequeueReusableSupplementaryView(ofKind: kind, for: indexPath)
    }
}
