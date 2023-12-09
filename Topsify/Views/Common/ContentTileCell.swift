//
//  ContentSquareCell.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-04.
//

import Combine
import Reusable
import UIKit

final class ContentTileCell: UICollectionViewCell, Reusable {
    static let defaultFixedWidth: CGFloat = 140
    static let estimatedHeight: CGFloat = 160

    private var imageViewWidthConstraint: NSLayoutConstraint!
    private var subtitleToTitleConstraint: NSLayoutConstraint!
    private var subtitleToImageConstraint: NSLayoutConstraint!
    
    private let imageView: RemoteImageView = {
        let view = RemoteImageView()
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private let titleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(ofSize: 14, weight: .bold)
        view.numberOfLines = 1
        view.textColor = .appTextPrimary
        return view
    }()
    
    private let subtitleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(ofSize: 14)
        view.numberOfLines = 2
        view.textColor = .appTextSecondary
        return view
    }()

    private let button = AppButton()

    private var isCircular: Bool = false {
        didSet {
            updateCornerRadius()
        }
    }

    private var disposeBag = DisposeBag()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(button)
        button.constrainEdgesToSuperview()

        button.contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: button.contentView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: button.contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: button.contentView.trailingAnchor).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true

        imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 0)
        
        button.contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 1.2).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: button.contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: button.contentView.trailingAnchor).isActive = true
        
        button.contentView.addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.leadingAnchor.constraint(equalTo: button.contentView.leadingAnchor).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: button.contentView.trailingAnchor).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: button.contentView.bottomAnchor).priorityAdjustment(-1).isActive = true
        
        subtitleToTitleConstraint = subtitleLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 0.9).isActive(true)
        subtitleToImageConstraint = subtitleLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 1.2).isActive(false)
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }

    func configure(
        with viewModel: ContentTileViewModel,
        fixedWidth: CGFloat? = defaultFixedWidth
    ) {
        disposeBag = DisposeBag()

        imageView.configure(with: viewModel.imageURL)

        subtitleToTitleConstraint.isActive = false
        subtitleToImageConstraint.isActive = false

        if let title = viewModel.title {
            subtitleToTitleConstraint.isActive = true
            titleLabel.text = title
            titleLabel.isHidden = false
        } else {
            subtitleToImageConstraint.isActive = true
            titleLabel.isHidden = true
        }

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.25
        subtitleLabel.attributedText = NSAttributedString(string: viewModel.subtitle, attributes: [.paragraphStyle: paragraphStyle])
        // explicitly set again so attributedText is affected
        // https://developer.apple.com/documentation/uikit/uilabel/1620525-linebreakmode
        subtitleLabel.lineBreakMode = .byTruncatingTail

        isCircular = viewModel.isCircular

        button.tapPublisher.sink(receiveValue: viewModel.onTap).store(in: &disposeBag)

        if let fixedWidth {
            imageViewWidthConstraint.constant = fixedWidth
            imageViewWidthConstraint.isActive = true
        } else {
            imageViewWidthConstraint.isActive = false
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    private func updateCornerRadius() {
        imageView.layer.cornerRadius = isCircular ? imageView.bounds.width / 2 : 0
    }
}
