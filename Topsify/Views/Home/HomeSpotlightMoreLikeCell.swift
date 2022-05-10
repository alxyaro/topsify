//
//  HomeSpotlightMoreLikeCell.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-05-03.
//

import UIKit
import Combine

class HomeSpotlightMoreLikeCell: UICollectionViewCell {
    private static let padding: CGFloat = 16
    private static let imageSize: CGFloat = 40
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .gray
        imageView.layer.cornerRadius = imageSize / 2
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let preLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextSecondary
        label.font = .appFont(ofSize: 10, weight: .regular)
        label.numberOfLines = 1
        label.text = "More like".uppercased()
        return label
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 21, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    private let contentRowView = ContentRowView()
    
    var cancellables = [AnyCancellable]()
    var viewModel: HomeSpotlightMoreLikeViewModel? {
        didSet {
            if oldValue === viewModel {
                return
            }
            cancellables = []
            
            if let avatar = viewModel?.userAvatar {
                imageView.image = avatar
            } else {
                imageView.image = nil
                viewModel?.$userAvatar.sink { [unowned self] avatar in
                    UIView.transition(with: imageView, duration: 0.2, options: [.transitionCrossDissolve]) {
                        imageView.image = avatar
                    }
                }.store(in: &cancellables)
            }
            
            label.text = viewModel?.user.name
            contentRowView.contentObjects = viewModel?.contentObjects ?? []
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let stackedTextLayoutGuide = UILayoutGuide()
        contentView.addLayoutGuide(stackedTextLayoutGuide)
        stackedTextLayoutGuide.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        stackedTextLayoutGuide.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        let imageButton = AppButton(contentView: imageView) {
            // ...
        }
        
        contentView.addSubview(imageButton)
        imageButton.translatesAutoresizingMaskIntoConstraints = false
        imageButton.widthAnchor.constraint(equalToConstant: Self.imageSize).isActive = true
        imageButton.heightAnchor.constraint(equalTo: imageButton.widthAnchor).isActive = true
        imageButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageButton.trailingAnchor.constraint(equalTo: stackedTextLayoutGuide.leadingAnchor, constant: -8).isActive = true
        imageButton.centerYAnchor.constraint(equalTo: stackedTextLayoutGuide.centerYAnchor).isActive = true

        contentView.addSubview(preLabel)
        preLabel.translatesAutoresizingMaskIntoConstraints = false
        preLabel.topAnchor.constraint(equalTo: stackedTextLayoutGuide.topAnchor).isActive = true
        preLabel.leadingAnchor.constraint(equalTo: stackedTextLayoutGuide.leadingAnchor).isActive = true
        preLabel.trailingAnchor.constraint(equalTo: stackedTextLayoutGuide.trailingAnchor).isActive = true
        
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: preLabel.lastBaselineAnchor, multiplier: 0.9).isActive = true
        label.leadingAnchor.constraint(equalTo: stackedTextLayoutGuide.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: stackedTextLayoutGuide.trailingAnchor).isActive = true
        label.lastBaselineAnchor.constraint(equalTo: stackedTextLayoutGuide.bottomAnchor).isActive = true
        
        contentView.addSubview(contentRowView)
        contentRowView.translatesAutoresizingMaskIntoConstraints = false
        contentRowView.topAnchor.constraint(equalToSystemSpacingBelow: label.lastBaselineAnchor, multiplier: 1).isActive = true
        contentRowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: -Self.padding).isActive = true
        contentRowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Self.padding).isActive = true
        contentRowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).priorityAdjustment(-1).isActive = true
        
        contentRowView.contentInset.left = Self.padding
        contentRowView.contentInset.right = Self.padding
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentRowView.contentOffset.x = -Self.padding
    }
}
