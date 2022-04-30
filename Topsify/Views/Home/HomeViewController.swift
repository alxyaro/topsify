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
    
    var headerSizeSubscriptionCancellable: AnyCancellable?
    let headerViewModel = HomeRecentListeningActivityViewModel()
    
    init() {
        super.init(collectionViewLayout: UICollectionViewFlowLayout())
        
        configureIdentity()
        configureCollectionViewLayout()
        
        collectionView.register(
            HomeRecentListeningActivityCell.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: HomeRecentListeningActivityCell.identifier
        )
        collectionView.contentInset.bottom = 1000
        collectionView.backgroundColor = .clear
        
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
    
    private func configureCollectionViewLayout() {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(60))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(50)) /* estimated should be smaller than actual */
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [header]
        section.interGroupSpacing = 15
        section.contentInsets.leading = 16
        section.contentInsets.trailing = 16
        
        collectionView.collectionViewLayout = UICollectionViewCompositionalLayout(section: section)
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
}

// MARK: - Delegate
extension HomeViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        mainScrollViewOnScroll?()
    }
}
