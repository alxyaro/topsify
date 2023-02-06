//
//  ContentRowView.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-04.
//

import UIKit

class ContentRowView: HorizontalCollectionView {
    var viewModels = [ContentSquareViewModel]()
    var contentObjects = [ContentObject]() {
        didSet {
            viewModels = contentObjects.map { ContentSquareViewModel(content: $0) }
            reloadData()
        }
    }
    
    init() {
        super.init(estimatedCellWidth: 140, estimatedCellHeight: 160)
        register(ContentSquareCell.self, forCellWithReuseIdentifier: ContentSquareCell.identifier)
        dataSource = self
        prefetchDataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension ContentRowView: UICollectionViewDataSource, UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ContentSquareCell.identifier, for: indexPath) as! ContentSquareCell
        guard let viewModel = viewModels[safe: indexPath.row] else {
            return cell
        }
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            viewModels[safe: indexPath.row]?.prefetchImage()
        }
    }
}
