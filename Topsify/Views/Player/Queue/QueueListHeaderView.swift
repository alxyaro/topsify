// Created by Alex Yaro on 2023-07-13.

import Reusable
import UIKit

final class QueueListHeaderView: UICollectionReusableView, Reusable {

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 16, weight: .bold)
        label.numberOfLines = 1
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .appBackground

        addSubview(headerLabel)
        headerLabel.constrainEdgesToSuperview(withInsets: .init(top: 8, leading: 16, bottom: 12, trailing: 8), withPriorities: .forCellSizing)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        headerLabel.text = nil
    }

    func configure(withText text: String) {
        headerLabel.text = text
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        // On the simulator, regular cells are above the header for some
        // reason, this prevents that:
        layer.zPosition = 2
    }
}
