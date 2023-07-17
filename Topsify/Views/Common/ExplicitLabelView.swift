// Created by Alex Yaro on 2023-07-12.

import UIKit

final class ExplicitLabelView: UIView {

    private let labelMask: UILabel = {
        let label = UILabel()

        label.textColor = .red
        label.numberOfLines = 1
        label.textAlignment = .center
        label.font = .appFont(ofSize: 9.5)
        label.text = NSLocalizedString("E", comment: "The 'E' contained inside the explicit content label/icon.")

        return label
    }()

    private lazy var labelInverseMask = InverseMaskView(labelMask)

    init() {
        super.init(frame: .zero)

        let view = UIView()
        view.backgroundColor = .appTextSecondary
        view.layer.cornerRadius = 2
        view.mask = labelInverseMask

        addSubview(view)
        view.constrainEdgesToSuperview()

        requireExactContentSize()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        labelInverseMask.frame = bounds
    }

    override var intrinsicContentSize: CGSize {
        let labelSize = labelMask.intrinsicContentSize
        let height = labelSize.height * 0.9
        return .init(width: max(height, labelSize.width + 2), height: height)
    }
}
