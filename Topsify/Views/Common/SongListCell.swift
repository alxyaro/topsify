// Created by Alex Yaro on 2023-07-11.

import Reusable
import UIKit

final class SongListCell: UICollectionViewListCell, Reusable {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 15)
        label.numberOfLines = 1
        return label
    }()

    private let explicitLabelView = ExplicitLabelView()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextSecondary
        label.font = .appFont(ofSize: 13)
        label.numberOfLines = 1
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
        backgroundConfiguration?.backgroundColor = .clear

        let subtitleStackView = UIStackView(arrangedSubviews: [explicitLabelView, subtitleLabel])
        subtitleStackView.axis = .horizontal
        subtitleStackView.alignment = .center
        subtitleStackView.spacing = 4

        let mainStackView = UIStackView(arrangedSubviews: [titleLabel, subtitleStackView])
        mainStackView.axis = .vertical
        mainStackView.spacing = 4

        contentView.addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview(withInsets: .init(horizontal: 16, vertical: 12), withPriorities: .forCellSizing)

        accessories = [
            .multiselect(displayed: .whenEditing),
            .reorder(displayed: .whenEditing)
        ]
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
}
