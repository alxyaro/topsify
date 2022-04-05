//
//  HorizontalCollectionView.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-04.
//

import UIKit

class HorizontalCollectionView: UICollectionView {
    private var heightConstraint: NSLayoutConstraint!

    init(fixedCellWidth: Int? = nil) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        backgroundColor = .clear
        
        // IMPORTANT: estimated size must be less than actual size, or
        // collectionViewContentSize will take on the large dimension
        
        let widthDimension = fixedCellWidth != nil ?
            NSCollectionLayoutDimension.absolute(CGFloat(fixedCellWidth!)) :
            NSCollectionLayoutDimension.estimated(1)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: .estimated(1))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal

        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        collectionViewLayout = layout
        
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = heightAnchor.constraint(equalToConstant: 50)
        heightConstraint.isActive = true
        
        showsHorizontalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heightConstraint.constant = collectionViewLayout.collectionViewContentSize.height
        layoutIfNeeded()
    }
}
