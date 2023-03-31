// Created by Alex Yaro on 2023-03-31.

import UIKit

final class PlayerSubMenuView: UIView {
    static let insets = NSDirectionalEdgeInsets(uniform: 10)

    private let outputDeviceButton = createButton(icon: "hifispeaker")
    private let shareButton = createButton(icon: "square.and.arrow.up")
    private let queueButton = createButton(icon: "list.bullet.below.rectangle")

    init() {
        super.init(frame: .zero)

        let mainStackView = UIStackView(arrangedSubviews: [
            outputDeviceButton,
            SpacerView(),
            shareButton,
            queueButton
        ])
        mainStackView.axis = .horizontal
        mainStackView.spacing = 32
        mainStackView.directionalLayoutMargins = Self.insets
        mainStackView.isLayoutMarginsRelativeArrangement = true

        addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func createButton(icon: String) -> AppButton {
        AppButton(icon: icon, size: 20, expandedTouchBoundary: Self.insets.toNonDirectionalInsets())
    }
}
