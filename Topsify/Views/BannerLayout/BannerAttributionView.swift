// Created by Alex Yaro on 2023-12-10.

import UIKit

final class BannerAttributionView: UIView {
    private static let avatarSize: CGFloat = 20

    private let avatarImagesContainer = UIView()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .firstBaseline
        stackView.spacing = 0
        return stackView
    }()

    private var disposeBag = DisposeBag()

    init(viewModel: BannerAttributionViewModel) {
        super.init(frame: .zero)

        setUpLayout()
        setUpContent(viewModel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpLayout() {
        let mainStackView = UIStackView(arrangedSubviews: [avatarImagesContainer, contentStackView])
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.spacing = 8

        addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview()
    }

    private func setUpContent(_ viewModel: BannerAttributionViewModel) {
        avatarImagesContainer.constrainDimensions(
            width: Self.avatarSize + Self.avatarSize * 0.5 * min(2, CGFloat(viewModel.attribution.count - 1)),
            height: Self.avatarSize
        )

        for (index, item) in viewModel.attribution.enumerated() {
            if index < 3 {
                let avatarImageView = RemoteImageView()
                avatarImageView.layer.cornerRadius = Self.avatarSize / 2
                avatarImageView.clipsToBounds = true
                avatarImageView.alpha = 1 - (CGFloat(index) / 3)
                avatarImageView.configure(with: item.avatarURL)
                avatarImageView.frame = CGRect(
                    x: Self.avatarSize * 0.5 * CGFloat(index),
                    y: 0,
                    width: Self.avatarSize,
                    height: Self.avatarSize
                )
                avatarImagesContainer.insertSubview(avatarImageView, at: 0)
            }

            let nameLabel = UILabel()
            nameLabel.text = item.name
            nameLabel.textColor = .appTextPrimary
            nameLabel.font = .appFont(ofSize: 13, weight: .bold)
            let nameButton = AppButton(contentView: nameLabel, scaleOnTap: false)

            nameButton.tapPublisher
                .mapToConstant(item)
                .sink(receiveValue: viewModel.onTap)
                .store(in: &disposeBag)

            contentStackView.addArrangedSubview(nameButton)

            if index < viewModel.attribution.count - 1 {
                let delimiterLabel = UILabel()
                delimiterLabel.text = NSLocalizedString(", ", comment: "Separator for a list of user names")
                delimiterLabel.font = .appFont(ofSize: 13)
                delimiterLabel.textColor = .appTextSecondary
                contentStackView.addArrangedSubview(delimiterLabel)
            }
        }
    }
}
