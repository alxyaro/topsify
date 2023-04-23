// Created by Alex Yaro on 2023-03-27.

import UIKit

final class PlayerTitleView: UIView {
    static let insets = NSDirectionalEdgeInsets(uniform: 10)

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 24, weight: .bold)
        label.textColor = .appTextPrimary
        label.text = "Some Lengthy Song (with Lil Artist Name Here)" // TODO: remove
        return label
    }()

    private let artistsLabel: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 16)
        label.textColor = .appTextSecondary
        label.text = "Artist Name, Some Other Artist" // TODO: remove
        return label
    }()

    private lazy var marqueeTitleLabel = MarqueeView(titleLabel)
    private lazy var marqueeArtistsLabel = MarqueeView(artistsLabel)

    private let addButton: AppButton = {
        let button = AppButton(icon: "plus.circle", size: 24)
        return button
    }()

    private let viewModel: PlayerTitleViewModel
    private var disposeBag = DisposeBag()

    init(viewModel: PlayerTitleViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupViews()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        let labelStackView = UIStackView(arrangedSubviews: [marqueeTitleLabel, marqueeArtistsLabel])
        labelStackView.axis = .vertical
        labelStackView.alignment = .fill
        labelStackView.spacing = 2

        let mainStackView = UIStackView(arrangedSubviews: [labelStackView, addButton])
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.spacing = 20
        mainStackView.directionalLayoutMargins = Self.insets
        mainStackView.isLayoutMarginsRelativeArrangement = true

        addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview()
    }

    private func bindViewModel() {
        let outputs = viewModel.bind(inputs: ())

        outputs.title
            .sink { [weak self] in
                self?.titleLabel.text = $0
                self?.marqueeTitleLabel.reset()
            }
            .store(in: &disposeBag)

        outputs.artists
            .sink { [weak self] in
                self?.artistsLabel.text = $0
                self?.marqueeArtistsLabel.reset()
            }
            .store(in: &disposeBag)
    }
}
