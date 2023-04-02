// Created by Alex Yaro on 2023-04-01.

import Reusable
import UIKit

final class PlayerStageBasicItemCell: UICollectionViewCell, Reusable {
    private let imageView = RemoteImageView()

    private var hasBeenVerticallyConstrained = false
    private var verticalConstraints = [NSLayoutConstraint]()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        contentView.addSubview(imageView)
        imageView.useAutoLayout()
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        imageView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 24).isActive = true
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        verticalConstraints.forEach {
            $0.isActive = superview != nil
        }
    }

    func constrain(verticallyInside layoutGuide: UILayoutGuide) {
        guard !hasBeenVerticallyConstrained else { return }

        verticalConstraints = [
            imageView.centerYAnchor.constraint(equalTo: layoutGuide.centerYAnchor),
            imageView.topAnchor.constraint(greaterThanOrEqualTo: layoutGuide.topAnchor)
        ]

        hasBeenVerticallyConstrained = true
    }

    func configure(tempImageURL: URL/*with ...*/) {
        imageView.configure(with: tempImageURL)
    }
}
