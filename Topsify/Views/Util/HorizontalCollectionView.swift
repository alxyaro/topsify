//
//  HorizontalCollectionView.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-04.
//

import UIKit

class HorizontalCollectionView: UICollectionView {
    private var heightConstraint: NSLayoutConstraint!

    init(estimatedCellWidth: CGFloat = 100, estimatedCellHeight: CGFloat = 100) {
        super.init(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        // IMPORTANT: estimated size must be less than actual size, or
        // collectionViewContentSize will take on the large dimension
        
        let widthDimension = NSCollectionLayoutDimension.estimated(estimatedCellWidth)
        let heightDimension = NSCollectionLayoutDimension.estimated(estimatedCellHeight)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: heightDimension)
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: widthDimension, heightDimension: heightDimension)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 15
        
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.scrollDirection = .horizontal

        let layout = UICollectionViewCompositionalLayout(section: section, configuration: config)
        collectionViewLayout = layout
        
        translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = heightAnchor.constraint(equalToConstant: 1)
        heightConstraint.priority -= 1
        heightConstraint.isActive = true
        
        showsHorizontalScrollIndicator = false
        
        // For some strange reason, a completely transparent background will result
        // in zero touch feedback where there isn't a child view; to work around this,
        // setting a practically invisible background color:
        backgroundColor = .appBackground.withAlphaComponent(0.001)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func reloadData() {
        heightConstraint.constant = 1
        setNeedsLayout()
        super.reloadData()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        heightConstraint.constant = collectionViewLayout.collectionViewContentSize.height
        layoutIfNeeded()
    }
    
    override func layoutMarginsDidChange() {
        super.layoutMarginsDidChange()
        contentInset.left = directionalLayoutMargins.leading
        contentInset.right = directionalLayoutMargins.trailing
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        // this matches AppButton & any other UIControl-s
        if view.isKind(of: UIControl.self) {
            return true
        }
        return super.touchesShouldCancel(in: view)
    }
}
