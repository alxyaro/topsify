//
//  ContentSquareCell.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-04.
//

import UIKit
import Combine

class ContentSquareCell: UICollectionViewCell {
    private var imageViewWidthConstraint: NSLayoutConstraint!
    private var subtitleToTitleConstraint: NSLayoutConstraint!
    private var subtitleToImageConstraint: NSLayoutConstraint!
    
    var imageFixedSize: CGFloat? {
        get {
            imageViewWidthConstraint.isActive ? imageViewWidthConstraint.constant : nil
        }
        set {
            if let newValue = newValue {
                imageViewWidthConstraint.isActive = true
                imageViewWidthConstraint.constant = newValue
            } else {
                imageViewWidthConstraint.isActive = false
            }
        }
    }
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .gray
        return view
    }()
    
    let titleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(ofSize: 14, weight: .bold)
        view.numberOfLines = 1
        view.textColor = .appTextPrimary
        return view
    }()
    
    let subtitleLabel: UILabel = {
        let view = UILabel()
        view.font = .appFont(ofSize: 14)
        view.numberOfLines = 2
        view.textColor = .appTextSecondary
        return view
    }()
    
    private var cancellables = [AnyCancellable]()
    var viewModel: ContentSquareViewModel? {
        didSet {
            if oldValue === viewModel {
                return
            }
            cancellables = []
            
            if let image = viewModel?.image {
                imageView.image = image
            } else {
                imageView.image = nil
                viewModel?.$image.sink(receiveValue: { [unowned self] image in
                    UIView.transition(with: imageView, duration: 0.2, options: [.transitionCrossDissolve]) {
                        imageView.image = image
                    }
                }).store(in: &cancellables)
            }
            setText(title: viewModel?.title, subtitle: viewModel?.subtitle ?? "")
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let button = AppButton()
        contentView.addSubview(button)
        button.constrain(into: contentView)
        
        button.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: button.contentView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: button.contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: button.contentView.trailingAnchor).isActive = true
        imageViewWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: 140).priorityAdjustment(-1).isActive(true)
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        button.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 1.2).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: button.contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: button.contentView.trailingAnchor).isActive = true
        
        button.addSubview(subtitleLabel)
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
    
    func setText(title: String?, subtitle: String) {
        if title == nil {
            subtitleToTitleConstraint.isActive = false
            subtitleToImageConstraint.isActive = true
            titleLabel.isHidden = true
        } else {
            subtitleToImageConstraint.isActive = false
            subtitleToTitleConstraint.isActive = true
            titleLabel.text = title
            titleLabel.isHidden = false
        }
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.25
        subtitleLabel.attributedText = NSAttributedString(string: subtitle, attributes: [.paragraphStyle: paragraphStyle])
        // explicitly set again so attributedTest is affected
        // https://developer.apple.com/documentation/uikit/uilabel/1620525-linebreakmode
        subtitleLabel.lineBreakMode = .byTruncatingTail
    }
    
}
