// Created by Alex Yaro on 2023-03-31.

import UIKit

final class PlayerSubMenuView: UIView {
    static let horizontalInset: CGFloat = 12

    private let outputDeviceButton = createButton(icon: "hifispeaker")
    private let shareButton = createButton(icon: "square.and.arrow.up")
    private let queueButton = createButton(icon: "list.bullet.below.rectangle")

    init() {
        super.init(frame: .zero)

        let mainStackView = UIStackView(arrangedSubviews: [
            outsetButton(outputDeviceButton),
            SpacerView(),
            outsetButton(shareButton),
            outsetButton(queueButton)
        ])
        mainStackView.directionalLayoutMargins = .init(horizontal: Self.horizontalInset, vertical: 0)
        mainStackView.isLayoutMarginsRelativeArrangement = true
        mainStackView.axis = .horizontal
        mainStackView.spacing = 32

        addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview()
        mainStackView.heightAnchor.constraint(equalToConstant: 36).isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func createButton(icon: String) -> AppButton {
        AppButton(icon: icon, size: 20)
    }

    private func outsetButton(_ button: AppButton) -> UIView {
        ExpandedTouchView(button, expandedBy: .init(horizontal: Self.horizontalInset, vertical: 0))
    }
}
