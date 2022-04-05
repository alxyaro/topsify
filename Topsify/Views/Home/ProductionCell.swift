//
//  ProductionCell.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-04.
//

import UIKit

class ProductionCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let view = UIImageView()
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
        view.numberOfLines = 1
        view.textColor = .appTextSecondary
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 140).priorityAdjustment(-1).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
        imageView.backgroundColor = .brown
        titleLabel.text = "Best Melodies"
        subtitleLabel.text = "Playlist"
        
        contentView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: imageView.bottomAnchor, multiplier: 1.2).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        
        contentView.addSubview(subtitleLabel)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.firstBaselineAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 0.9).isActive = true
        subtitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        subtitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).priorityAdjustment(-1).isActive = true
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
    
}
