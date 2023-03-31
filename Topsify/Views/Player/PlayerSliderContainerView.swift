// Created by Alex Yaro on 2023-03-26.

import UIKit

final class PlayerSliderContainerView: UIView {
    static let insets = NSDirectionalEdgeInsets(uniform: PlayerSlider.inset)

    private let slider = PlayerSlider()

    private let leadingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 13)
        label.textColor = .appTextSecondary
        label.text = "-:--"
        return label
    }()

    private let trailingTimeLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 13)
        label.textColor = .appTextSecondary
        label.text = "-:--"
        return label
    }()

    init() {
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let timeLabelsStackView = UIStackView(arrangedSubviews: [leadingTimeLabel, trailingTimeLabel])
        timeLabelsStackView.axis = .horizontal
        timeLabelsStackView.distribution = .equalSpacing
        timeLabelsStackView.alignment = .center

        let mainStackView = UIStackView(arrangedSubviews: [
            OverhangingView(slider, horizontalOverhang: PlayerSlider.inset),
            timeLabelsStackView
        ])
        mainStackView.axis = .vertical
        mainStackView.alignment = .fill
        mainStackView.spacing = 3 - PlayerSlider.inset
        mainStackView.bringSubviewToFront(slider)
        mainStackView.directionalLayoutMargins = Self.insets
        mainStackView.isLayoutMarginsRelativeArrangement = true

        addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview()
    }
}
