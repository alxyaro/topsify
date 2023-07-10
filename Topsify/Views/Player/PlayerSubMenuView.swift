// Created by Alex Yaro on 2023-03-31.

import UIKit

final class PlayerSubMenuView: UIView {
    private let outputDeviceButton = createButton(icon: "Icons/devices", scale: 0.8)
    private let shareButton = createButton(icon: "Icons/share")
    private let queueButton = createButton(icon: "Icons/queue")

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
        mainStackView.directionalLayoutMargins = .init(horizontal: PlayerViewConstants.contentSidePadding, vertical: 10)
        mainStackView.isLayoutMarginsRelativeArrangement = true

        addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private static func createButton(icon: String, scale: CGFloat = 1) -> AppButton {
        AppIconButton(icon: icon, scale: scale)
    }
}
