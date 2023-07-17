// Created by Alex Yaro on 2023-07-11.

import Reusable
import UIKit

final class SongListCell: UICollectionViewListCell, Reusable {

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

        let subtitleStackView = UIStackView(arrangedSubviews: [explicitLabelView, subtitleLabel])
        subtitleStackView.axis = .horizontal
        subtitleStackView.alignment = .center
        subtitleStackView.spacing = 4

        let mainStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 4

        contentView.addSubview(mainStackView)
        mainStackView.useAutoLayout()
        mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16).fixCellConstraintErrors().isActive = true
        mainStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12).priority(.justLessThanRequired).isActive = true

        accessories = [
            .multiselect(displayed: .whenEditing),
            .reorder(displayed: .whenEditing)
        ]
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
    }

    func configure(with viewModel: SongListCellViewModel) {
        let outputs = viewModel.outputs()

        titleLabel.text = outputs.title
        subtitleLabel.text = outputs.subtitle
        explicitLabelView.isHidden = !outputs.isExplicitLabelVisible
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
