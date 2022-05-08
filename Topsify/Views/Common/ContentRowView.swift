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
        super.init()
        register(ContentSquareCell.self, forCellWithReuseIdentifier: ContentSquareCell.identifier)
        dataSource = self
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
        let viewModel = viewModels[indexPath.row]
        viewModel.loadImage()
        cell.viewModel = viewModel
        cell.setNeedsLayout()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { indexPath in
            viewModels[indexPath.row].loadImage()
        }
    }
}
