// Created by Alex Yaro on 2023-06-18.

import UIKit

final class PlayBarView: UIView {

    private let artworkImageView: RemoteImageView = {
        let imageView = RemoteImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.constrainDimensions(uniform: 40)
        imageView.layer.cornerRadius = 4
        imageView.clipsToBounds = true
        return imageView
    }()

    private lazy var artworkContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = artworkImageView.layer.cornerRadius

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.5
        view.layer.shadowRadius = 6
        view.layer.shadowOffset = .zero

        view.addSubview(artworkImageView)
        artworkImageView.constrainEdgesToSuperview()

        return view
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
            artworkContainerView,
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

    private let viewModel: PlayBarViewModel
    private var disposeBag = DisposeBag()

    init(viewModel: PlayBarViewModel) {
        self.viewModel = viewModel

        super.init(frame: .zero)

        setUpView()
        bindViewModel()
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

    private func bindViewModel() {
        let outputs = viewModel.bind(inputs: .init(
            changedActiveItemIndex: detailsView.selectedIndexPublisher
        ))

        outputs.artworkURL
            .sink { [weak self] in
                self?.artworkImageView.configure(with: $0)
            }
            .store(in: &disposeBag)

        outputs.itemList
            .sink { [weak self] in
                self?.detailsView.updateItemList($0)
            }
            .store(in: &disposeBag)

        outputs.backgroundColor
            .sink { [weak self] color in
                UIView.animate(withDuration: 0.4, delay: 0, options: [.allowAnimatedContent, .allowUserInteraction]) {
                    self?.backgroundColor = color.uiColor
                }
            }
            .store(in: &disposeBag)
    }

    private static func createSideButton(icon: String, tintColor: UIColor = .primaryIcon) -> AppIconButton {
        let button = AppIconButton(icon: icon, size: .uniform(52), expandedTouchBoundary: .zero)
        button.tintColor = tintColor
        return button
    }
}
