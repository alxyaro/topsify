//
//  HomeViewController.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-27.
//

import UIKit
import Combine

class HomeViewController: AppNavigableController {
    
    let viewModel: HomeViewModel
    let headerViewModel: HomeRecentListeningActivityViewModel
    private var cancellables = [AnyCancellable]()
    private var headerSizeSubscriptionCancellable: AnyCancellable?
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    private let backgroundGradient = CAGradientLayer()
    
    init(
        viewModel: HomeViewModel = HomeViewModel(),
        headerViewModel: HomeRecentListeningActivityViewModel = HomeRecentListeningActivityViewModel()
    ) {
        self.viewModel = viewModel
        self.headerViewModel = headerViewModel
        
        super.init()
        
        configureNavigation()
        configureCollectionView()
        configureBackgroundGradient()
        
        viewModel.$spotlight.sink { [unowned self] _ in
            collectionView.reloadData()
        }.store(in: &cancellables)
        
        viewModel.load()
        headerViewModel.loadData()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTimeDynamicStyles()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        backgroundGradient.anchorPoint = .zero
        backgroundGradient.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
    }
    
    // MARK: - Helpers

    private func configureNavigation() {
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
        collectionView.dataSource = self
        collectionView.delegate = self
        
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
        
        view.addSubview(collectionView)
        collectionView.constrain(into: view)
    }
    
    private func configureBackgroundGradient() {
        backgroundGradient.type = .axial
        backgroundGradient.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor]
        backgroundGradient.startPoint = .zero
        backgroundGradient.endPoint = CGPoint(x: 0.4, y: 0.8)
        
        view.layer.insertSublayer(backgroundGradient, at: 0)
    }
    
    private func updateTimeDynamicStyles() {
        let hour = Calendar.current.component(.hour, from: Date())
        
        var timeOfDay: String
        if hour < 5 {
            timeOfDay = "night"
        } else if hour < 12 {
            timeOfDay = "morning"
        } else if hour < 18 {
            timeOfDay = "afternoon"
        } else {
            timeOfDay = "evening"
        }
        
        title = "Good "+timeOfDay
        if let color = UIColor(named: "HomeTimeTints/\(timeOfDay.capitalized)Color") {
            backgroundGradient.colors?[0] = color.withAlphaComponent(0.4).cgColor
        }
    }
}

// MARK: - Data Source
extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeRecentListeningActivityCell.identifier, for: indexPath) as! HomeRecentListeningActivityCell
        cell.configure(with: headerViewModel, onSizeUpdate: {
            collectionView.performBatchUpdates(nil)
        })
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.spotlight.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
            cell.configure(with: HomeSpotlightMoreLikeViewModel(user: user, contentObjects: content))
            cell.setNeedsLayout()
            cell.layoutIfNeeded()
            return cell
        }
    }
}

// MARK: - Collection View Delegate
extension HomeViewController: UICollectionViewDelegate {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        backgroundGradient.position.y = min(0, -(scrollView.contentOffset.y + scrollView.adjustedContentInset.top) / 2)
        CATransaction.commit()
    }
}
