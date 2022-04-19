//
//  HomeRecentArtifactsCell.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-16.
//

import UIKit

class HomeRecentArtifactsCell: UICollectionViewCell {
    private var collectionView: UICollectionView!
    private var heightConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        // TODO: convert to diffable data source
        collectionView.dataSource = self
        collectionView.register(HomeRecentArtifactCell.self, forCellWithReuseIdentifier: HomeRecentArtifactCell.identifier)
        
        contentView.addSubview(collectionView)
        collectionView.constrain(into: contentView)
        heightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0).isActive(false)
        heightConstraint.priority -= 1
        
        // This might seem dumb, but two layouts are actually necessary here
        // The first run causes cells to be created (but only after layoutSubviews()...)
        // The second run can then use the established collectionViewContentSize
        setNeedsLayout()
        layoutIfNeeded()
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(55))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        heightConstraint.constant = collectionView.collectionViewLayout.collectionViewContentSize.height
        heightConstraint.isActive = true
    }
}

extension HomeRecentArtifactsCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeRecentArtifactCell.identifier, for: indexPath) as! HomeRecentArtifactCell
        cell.viewModel = HomeRecentArtifactViewModel()
        return cell
    }
}
