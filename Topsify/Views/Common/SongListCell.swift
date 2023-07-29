// Created by Alex Yaro on 2023-07-11.

import Reusable
import UIKit

protocol SongListCellDelegate: AnyObject {
    func songListCellTapped(_ cell: SongListCell)
    func songListCellOptionsButtonTapped(_ cell: SongListCell)
}

final class SongListCell: UICollectionViewListCell, Reusable {
    private static let accessoryTintColor = UIColor(named: "ListAccessoryTintColor")
    private static let accessoryActiveColor = UIColor.appTextPrimary

    struct Options {
        var showThumbnail = false
        var includeEditingAccessories = false
    }

    private let thumbnailView = ThumbnailView()

    private let optionsButton: AppIconButton = {
        let button = AppIconButton(icon: "Icons/options", scale: 0.9)
        button.tintColor = .appTextSecondary
        button.constrainHeight(to: 30)
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 15)
        label.numberOfLines = 1
        label.requireIntrinsicHeight()
        return label
    }()

    private let explicitLabelView = ExplicitLabelView()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextSecondary
        label.font = .appFont(ofSize: 13)
        label.numberOfLines = 1
        label.requireIntrinsicHeight()
        return label
    }()

    private weak var delegate: SongListCellDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)

        setUpView()
        setUpUserInteraction()
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

        let mainStackView = UIStackView(arrangedSubviews: [thumbnailView, titleStackView, optionsButton])
        mainStackView.axis = .horizontal
        mainStackView.spacing = 12
        mainStackView.alignment = .center
        mainStackView.directionalLayoutMargins = .horizontal(16)
        mainStackView.isLayoutMarginsRelativeArrangement = true

        contentView.addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview(excluding: .vertical, withPriorities: .forCellSizing)
        titleStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        titleStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).priority(.justLessThanRequired).isActive = true
    }

    private func setUpUserInteraction() {
        let contentTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleContentTap))
        contentTapGestureRecognizer.delegate = self
        contentView.addGestureRecognizer(contentTapGestureRecognizer)

        optionsButton.addTarget(self, action: #selector(handleOptionsButtonTap), for: .touchUpInside)
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

    func configure(with viewModel: SongListCellViewModel, delegate: SongListCellDelegate?, options: Options = .init()) {
        self.delegate = delegate

        directionalLayoutMargins = .horizontal(16)

        titleLabel.text = viewModel.outputs.title
        subtitleLabel.text = viewModel.outputs.subtitle
        explicitLabelView.isHidden = !viewModel.outputs.showExplicitLabel
        optionsButton.isHidden = !viewModel.outputs.showOptionsButton

        if options.showThumbnail {
            thumbnailView.isHidden = false
            thumbnailView.configure(with: viewModel.outputs.artworkURL)
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

    @objc private func handleContentTap() {
        delegate?.songListCellTapped(self)
    }

    @objc private func handleOptionsButtonTap() {
        delegate?.songListCellOptionsButtonTapped(self)
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

extension SongListCell: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return !(touch.view is UIControl)
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
