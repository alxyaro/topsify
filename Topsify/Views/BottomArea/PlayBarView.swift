// Created by Alex Yaro on 2023-06-18.

import UIKit

final class PlayBarView: UIView {

    private let artworkImageView: RemoteImageView = {
        let imageView = RemoteImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.constrainDimensions(uniform: 40)
        imageView.layer.cornerRadius = 4

        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowRadius = 6
        imageView.layer.shadowOffset = .zero

        return imageView
    }()

    private let detailsMaskView = HorizontalGradientMaskView(gradientSize: 8)

    private lazy var detailsView: PlayBarDetailsView = {
        let view = PlayBarDetailsView()
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.mask = detailsMaskView
        return view
    }()

    private let devicesButton = createSideButton(icon: "Icons/devices", tintColor: .secondaryIcon)

    private let playPauseButton = createSideButton(icon: "Icons/play")

    private let progressBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "BottomArea/playBarProgressBackgroundColor")
        view.heightAnchor.constraint(equalToConstant: 2).isActive = true
        view.layer.cornerRadius = 1
        view.clipsToBounds = true
        return view
    }()

    private let progressView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "BottomArea/playBarProgressColor")
        return view
    }()

    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            artworkImageView,
            detailsView,
            devicesButton,
            playPauseButton
        ])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins.leading = 8
        return stackView
    }()

    init() {
        super.init(frame: .zero)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        /// This is necessary to ensure frames are ready; see https://stackoverflow.com/a/61751851
        mainStackView.layoutIfNeeded()

        artworkImageView.layer.shadowPath = UIBezierPath(
            roundedRect: artworkImageView.bounds,
            cornerRadius: artworkImageView.layer.cornerRadius
        ).cgPath
        detailsMaskView.frame = detailsView.bounds
    }

    private func setUpView() {
        layer.cornerRadius = 6
        backgroundColor = .darkGray

        addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview(withInsets: .bottom(1))
        artworkImageView.topAnchor.constraint(greaterThanOrEqualTo: mainStackView.topAnchor, constant: 8).isActive = true
        detailsView.heightAnchor.constraint(equalTo: mainStackView.heightAnchor).isActive = true

        addSubview(progressBackgroundView)
        progressBackgroundView.constrainEdgesToSuperview(excluding: .top, withInsets: .horizontal(9))

        progressBackgroundView.addSubview(progressView)
        progressView.constrainEdgesToSuperview(excluding: .trailing)
        progressView.widthAnchor.constraint(equalTo: progressBackgroundView.widthAnchor, multiplier: 0.3).isActive = true
    }

    private static func createSideButton(icon: String, tintColor: UIColor = .primaryIcon) -> AppIconButton {
        let button = AppIconButton(icon: icon, size: 24, buttonSize: 52)
        button.tintColor = tintColor
        return button
    }
}
