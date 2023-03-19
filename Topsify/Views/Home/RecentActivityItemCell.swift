// Created by Alex Yaro on 2022-04-16.

import Combine
import Reusable
import UIKit

final class RecentActivityItemCell: UICollectionViewCell, Reusable {
    static let height: CGFloat = 55

    private let imageView: RemoteImageView = {
        let imageView = RemoteImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 14, weight: .bold)
        label.textColor = .appTextPrimary
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .appCardBackground
        layer.cornerRadius = 5
        clipsToBounds = true

        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true

        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true

        // this is to avoid all the views animating from a zero frame
        UIView.performWithoutAnimation {
            layoutIfNeeded()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.reset()
    }

    func configure(with viewModel: RecentActivityItemViewModel) {
        label.text = viewModel.title
        imageView.configure(with: viewModel.imageURL)
    }
}
