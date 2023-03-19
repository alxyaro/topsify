// Created by Alex Yaro on 2023-03-01.

import Reusable
import UIKit

final class HomeSimpleHeaderCell: UICollectionReusableView, Reusable {

    private let headingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 21, weight: .bold)
        label.numberOfLines = 3
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(headingLabel)
        headingLabel.constrainEdgesToSuperview(withInsets: .bottom(16))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(heading: String) {
        headingLabel.text = heading
    }
}
