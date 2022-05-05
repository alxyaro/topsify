//
//  HomeSpotlightMoreLikeCell.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-05-03.
//

import UIKit

class HomeSpotlightMoreLikeCell: UICollectionViewCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // TODO: implement
        contentView.backgroundColor = .systemPink
        contentView.heightAnchor.constraint(equalToConstant: 100).priorityAdjustment(-1).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
