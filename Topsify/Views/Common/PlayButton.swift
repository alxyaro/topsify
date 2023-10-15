// Created by Alex Yaro on 2023-08-06.

import UIKit

final class PlayButton: AppIconButton {
    static let size: CGFloat = 48

    private static let playIcon = "Icons/playCentered"
    private static let pauseIcon = "Icons/pause"

    private var verticalConstraint: NSLayoutConstraint?

    init() {
        super.init(icon: Self.playIcon, size: .uniform(Self.size))
        tintColor = .appBackground
        contentView.backgroundColor = .accent
        contentView.layer.cornerRadius = Self.size / 2

        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.1
        contentView.layer.shadowRadius = 6
        contentView.layer.shadowOffset = .zero
        contentView.layer.shadowPath = UIBezierPath(roundedRect: .init(origin: .zero, size: .uniform(Self.size)), cornerRadius: Self.size / 2).cgPath
    }

    func constrainVertically(with anchor: NSLayoutYAxisAnchor) {
        verticalConstraint?.isActive = false
        verticalConstraint = centerYAnchor.constraint(greaterThanOrEqualTo: anchor).isActive(true)
    }
}
