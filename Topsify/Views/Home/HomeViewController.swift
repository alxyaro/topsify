//
//  HomeViewController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-27.
//

import UIKit
import Combine

class HomeViewController: UICollectionViewController, AppNavigableController {
    var isNavBarSticky = false
    var navBarButtons = [AppNavigationBarButton]()
    var mainScrollView: UIScrollView? {
        collectionView
    }
    var mainScrollViewOnScroll: AppNavigableController.ScrollCallback?
    
    private var cancellables = [AnyCancellable]()
    let viewModel: HomeViewModel
    let headerViewModel: HomeRecentListeningActivityViewModel
    
    var headerSizeSubscriptionCancellable: AnyCancellable?
    
    init(
        viewModel: HomeViewModel = HomeViewModel(),
        headerViewModel: HomeRecentListeningActivityViewModel = HomeRecentListeningActivityViewModel()
    ) {
        self.viewModel = viewModel
        self.headerViewModel = headerViewModel
        
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        
        configureIdentity()
        configureCollectionView()
        
        viewModel.$spotlight.sink { [unowned self] _ in
            collectionView.reloadData()
        }.store(in: &cancellables)
        
        viewModel.load()
        headerViewModel.loadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureIdentity() {
        title = "Good Evening"
        navBarButtons += [
            AppNavigationBarButton(iconName: "bell", onTap: {
                
            }),
            AppNavigationBarButton(iconName: "clock.arrow.circlepath", onTap: {
                
            }),
            AppNavigationBarButton(iconName: "gear", onTap: {
                self.navigationController?.pushViewController(HomeViewController(), animated: true)
            })
        ]
    }
    
    private func configureCollectionView() {
        // god bless https://stackoverflow.com/questions/58339188/collection-view-compositional-layout-with-estimated-height-not-working
        // if you give the itemSize height a .fractionalWidth(1) as would be a rational approach, with an estimated
        // size on the group, the group estimated size will just become FIXED! Putting an estimated height here actually
        // fixes that and allows each cell to expand if it needs more size than the estimated value
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(160))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(160))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 1)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)) /* estimated should be smaller than actual */
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 24
        section.contentInsets.top = 24
        section.contentInsets.leading = 16
        section.contentInsets.trailing = 16
        
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
        
        collectionView.register(
            HomeRecentListeningActivityCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeRecentListeningActivityCell.identifier
        )
        collectionView.register(
            HomeSpotlightContentListCell.self,
            forCellWithReuseIdentifier: HomeSpotlightContentListCell.identifier
        )
        collectionView.register(
            HomeSpotlightMoreLikeCell.self,
            forCellWithReuseIdentifier: HomeSpotlightMoreLikeCell.identifier
        )
        collectionView.backgroundColor = .clear
    }
}

// MARK: - Data Source
extension HomeViewController {
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeRecentListeningActivityCell.identifier, for: indexPath) as! HomeRecentListeningActivityCell
        cell.viewModel = headerViewModel
        headerSizeSubscriptionCancellable = cell.didUpdateLayout.sink {
            collectionView.collectionViewLayout.invalidateLayout()
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.spotlight.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch viewModel.spotlight[indexPath.row] {
        case .contentList(let title, let content):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSpotlightContentListCell.identifier, for: indexPath) as! HomeSpotlightContentListCell
            cell.label.text = title
            cell.contentRowView.contentObjects = content
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
        case .moreLike(let user, let content):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeSpotlightMoreLikeCell.identifier, for: indexPath) as! HomeSpotlightMoreLikeCell
            cell.viewModel = HomeSpotlightMoreLikeViewModel(user: user, contentObjects: content)
            cell.viewModel?.loadUserAvatar()
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
        }
    }
}

// MARK: - Delegate
extension HomeViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        mainScrollViewOnScroll?()
    }
}
