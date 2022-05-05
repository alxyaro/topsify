//
//  HomeSpotlightContentListCell.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-05-03.
//

import UIKit

class HomeSpotlightContentListCell: UICollectionViewCell {
    
    let label: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 21, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    let contentRowView = ContentRowView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        
        contentView.addSubview(contentRowView)
        contentRowView.translatesAutoresizingMaskIntoConstraints = false
        contentRowView.topAnchor.constraint(equalToSystemSpacingBelow: label.lastBaselineAnchor, multiplier: 1).isActive = true
        contentRowView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        contentRowView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        contentRowView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).priorityAdjustment(-1).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
