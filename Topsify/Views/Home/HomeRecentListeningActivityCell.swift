//
//  HomeRecentListeningActivityCell.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-16.
//

import UIKit
import Combine

class HomeRecentListeningActivityCell: UICollectionViewCell {
    private var cancellables = [AnyCancellable]()
    var viewModel: HomeRecentListeningActivityViewModel? {
        didSet {
            if oldValue === viewModel {
                return
            }
            cancellables = []
            guard let viewModel = viewModel else {
                return
            }
            viewModel.$recentActivity.sink { [unowned self] recentActivity in
                collectionView.reloadData()
                
                setNeedsLayout()
                layoutIfNeeded()
                didUpdateLayout.send()
            }.store(in: &cancellables)
        }
    }
    let didUpdateLayout = PassthroughSubject<Void, Never>()
    
    private var collectionView: UICollectionView!
    private var heightConstraint: NSLayoutConstraint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.register(HomeRecentListeningActivityItemCell.self, forCellWithReuseIdentifier: HomeRecentListeningActivityItemCell.identifier)
        
        contentView.addSubview(collectionView)
        collectionView.constrain(into: contentView)
        heightConstraint = contentView.heightAnchor.constraint(equalToConstant: 0).isActive(true)
        heightConstraint.priority -= 1
        
        // keep this; it ensures accurate layout in case the viewModel callback is
        // executed immediately after init (via testing)
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

extension HomeRecentListeningActivityCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.recentActivity.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeRecentListeningActivityItemCell.identifier, for: indexPath) as! HomeRecentListeningActivityItemCell
        cell.viewModel = HomeRecentListeningActivityItemViewModel(contentObject: viewModel!.recentActivity[indexPath.row])
        cell.viewModel?.loadThumbnail()
        return cell
    }
}
