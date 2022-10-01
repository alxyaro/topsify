//
//  HomeRecentListeningActivityCell.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-16.
//

import UIKit
import Combine

class HomeRecentListeningActivityCell: UICollectionViewCell {
    private var collectionView: UICollectionView!
    private var heightConstraint: NSLayoutConstraint!

    private var collectionViewLayout: UICollectionViewLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(55))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(8)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8

        return UICollectionViewCompositionalLayout(section: section)
    }()

    private var cancellables = [AnyCancellable]()
    private var viewModel: HomeRecentListeningActivityViewModel?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.register(HomeRecentListeningActivityItemCell.self, forCellWithReuseIdentifier: HomeRecentListeningActivityItemCell.identifier)
        
        contentView.addSubview(collectionView)
        collectionView.constrain(into: contentView)
        heightConstraint = contentView.heightAnchor.constraint(equalToConstant: 1).isActive(true)
        heightConstraint.priority -= 1
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: HomeRecentListeningActivityViewModel, onSizeUpdate: @escaping () -> Void) {
        guard self.viewModel !== viewModel else { return }
        self.viewModel = viewModel

        cancellables = []
        viewModel.$recentActivity.sink { [unowned self] recentActivity in

            collectionViewLayout.invalidateLayout()
            collectionView.reloadData()

            setNeedsLayout()
            layoutIfNeeded()

            let lastHeight = heightConstraint.constant
            // height must remain at least 1 (non-zero frame), as otherwise collectionViewContentSize
            // seems to always be zero (assuming it's calculation for a zero-frame collection view?)
            heightConstraint.constant = max(1, collectionViewLayout.collectionViewContentSize.height)

            if lastHeight != heightConstraint.constant {
                onSizeUpdate()
            }
        }.store(in: &cancellables)
    }
}

extension HomeRecentListeningActivityCell: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel?.recentActivity.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeRecentListeningActivityItemCell.identifier, for: indexPath) as! HomeRecentListeningActivityItemCell

        let viewModel = HomeRecentListeningActivityItemViewModel(contentObject: viewModel!.recentActivity[indexPath.row])
        viewModel.loadThumbnail()
        cell.configure(with: viewModel)

        return cell
    }
}
