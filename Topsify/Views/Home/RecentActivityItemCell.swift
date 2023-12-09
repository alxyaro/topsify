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

    private let buttonContainer = AppButton()
    private var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let containerView = buttonContainer.contentView

        containerView.backgroundColor = .appCardBackground
        containerView.layer.cornerRadius = 5
        containerView.clipsToBounds = true

        contentView.addSubview(buttonContainer)
        buttonContainer.constrainEdgesToSuperview()

        containerView.addSubview(imageView)
        imageView.constrainEdgesToSuperview(excluding: .trailing)
        imageView.constrainWidthToHeight()

        containerView.addSubview(label)
        label.useAutoLayout()
        label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        label.constrainVerticallyInCenter(of: containerView)

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

        disposeBag = DisposeBag()
        buttonContainer.tapPublisher.sink(receiveValue: viewModel.onTap).store(in: &disposeBag)
    }
}
