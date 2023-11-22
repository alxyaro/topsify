// Created by Alex Yaro on 2023-03-01.

import Reusable
import UIKit

final class LabelHeaderCell: UICollectionReusableView, Reusable {
    static let kind = UICollectionView.elementKindSectionHeader

    struct Style {
        static let `default` = Style(font: .appFont(ofSize: 17, weight: .bold))

        let font: UIFont
    }

    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        label.requireIntrinsicHeight()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        useCollectionViewLayoutMargins()
        directionalLayoutMargins = .bottom(16)

        addSubview(label)
        label.constrainEdges(to: layoutMarginsGuide)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        label.text = nil
        directionalLayoutMargins.top = 0
    }

    func configure(
        text: String,
        style: Style = .default,
        topPadding: CGFloat = 0,
        bottomPadding: CGFloat = 12
    ) {
        label.text = text
        label.font = style.font
        directionalLayoutMargins.top = topPadding
        directionalLayoutMargins.bottom = bottomPadding
    }
}

extension LabelHeaderCell {

    static func compositionalLayoutSupplementaryItem(estimatedHeight: CGFloat = 55) -> NSCollectionLayoutBoundarySupplementaryItem {
        .init(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(estimatedHeight)),
            elementKind: Self.kind,
            alignment: .top
        )
    }
}
