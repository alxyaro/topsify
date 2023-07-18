// Created by Alex Yaro on 2023-07-11.

import Reusable
import UIKit

final class SongListCell: UICollectionViewListCell, Reusable {
    private static let accessoryTintColor = UIColor(named: "ListAccessoryTintColor")
    private static let accessoryActiveColor = UIColor.appTextPrimary

    private let thumbnailView = ThumbnailView()

    struct Options {
        var showThumbnail = false
        var includeEditingAccessories = false
    }

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 15)
        label.numberOfLines = 1
        label.requireExactHeight()
        return label
    }()

    private let explicitLabelView = ExplicitLabelView()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextSecondary
        label.font = .appFont(ofSize: 13)
        label.numberOfLines = 1
        label.requireExactHeight()
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        backgroundConfiguration = .clear()
        contentView.clipsToBounds = true

        let subtitleStackView = UIStackView(arrangedSubviews: [explicitLabelView, subtitleLabel])
        subtitleStackView.axis = .horizontal
        subtitleStackView.alignment = .center
        subtitleStackView.spacing = 4

        let titleStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleStackView])
        titleStackView.axis = .vertical
        titleStackView.spacing = 4

        let mainStackView = UIStackView(arrangedSubviews: [thumbnailView, titleStackView])
        mainStackView.axis = .horizontal
        mainStackView.spacing = 12
        mainStackView.alignment = .center

        contentView.addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview(excluding: .vertical, withInsets: .horizontal(16), withPriorities: .forCellSizing)
        titleStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).priority(.justLessThanRequired).isActive = true
    }

    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        layer.zPosition = CGFloat(layoutAttributes.zIndex)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        subtitleLabel.text = nil
        explicitLabelView.isHidden = true

        thumbnailView.isHidden = true
        accessories = []
    }

    func configure(with viewModel: SongListCellViewModel, options: Options = .init()) {
        directionalLayoutMargins = .horizontal(16)

        let outputs = viewModel.outputs()

        titleLabel.text = outputs.title
        subtitleLabel.text = outputs.subtitle
        explicitLabelView.isHidden = !outputs.isExplicitLabelVisible

        if options.showThumbnail {
            thumbnailView.isHidden = false
            thumbnailView.configure(with: outputs.artworkURL)
        } else {
            thumbnailView.isHidden = true
        }

        if options.includeEditingAccessories {
            accessories += [
                .multiselect(
                    displayed: .whenEditing,
                    options: .init(
                        reservedLayoutWidth: .custom(40),
                        tintColor: Self.accessoryTintColor,
                        backgroundColor: Self.accessoryActiveColor
                    )
                ),
                .reorder(
                    displayed: .whenEditing,
                    options: .init(tintColor: Self.accessoryTintColor)
                )
            ]
        }
    }

    static func computePreferredHeight() -> CGFloat {
        let sampleCell = SongListCell(frame: .zero)
        sampleCell.titleLabel.text = "Title"
        sampleCell.subtitleLabel.text = "Subtitle"
        sampleCell.explicitLabelView.isHidden = false
        let size = sampleCell.systemLayoutSizeFitting(.init(width: 400, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
        return size.height
    }
}

private extension SongListCell {

    final class ThumbnailView: UIView {

        private let imageView: RemoteImageView = {
            let imageView = RemoteImageView()
            imageView.layer.cornerRadius = 4
            imageView.clipsToBounds = true
            imageView.constrainDimensions(uniform: 45)
            return imageView
        }()

        init() {
            super.init(frame: .zero)

            addSubview(imageView)
            imageView.constrainEdgesToSuperview(excluding: .vertical)
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: topAnchor).priority(.justLessThanRequired).isActive = true
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        func configure(with imageURL: URL) {
            imageView.configure(with: imageURL)
        }
    }
}
