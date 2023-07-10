// Created by Alex Yaro on 2023-03-26.

import UIKit

final class PlayerSliderContainerView: UIView {
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
        let extraSliderSidePadding = PlayerViewConstants.contentSidePadding - PlayerSlider.padding

        addSubview(slider)
        slider.useAutoLayout()
        slider.topAnchor.constraint(equalTo: topAnchor).isActive = true
        slider.leadingAnchor.constraint(equalTo: leadingAnchor, constant: extraSliderSidePadding).isActive = true
        slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -extraSliderSidePadding).isActive = true
        slider.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor).isActive = true

        let timeLabelsStackView = UIStackView(arrangedSubviews: [leadingTimeLabel, trailingTimeLabel])
        timeLabelsStackView.axis = .horizontal
        timeLabelsStackView.distribution = .equalSpacing
        timeLabelsStackView.alignment = .center

        addSubview(timeLabelsStackView)
        timeLabelsStackView.constrainEdges(to: slider, excluding: .vertical, withInsets: .horizontal(PlayerSlider.padding))
        timeLabelsStackView.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 3 - PlayerSlider.padding).isActive = true
        timeLabelsStackView.bottomAnchor.constraint(equalTo: bottomAnchor).priority(.justLessThanRequired).isActive = true

        // Bring slider to front so it gets priority on touch events:
        bringSubviewToFront(slider)
    }
}
