//
//  ProductionCollectionView.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-04.
//

import UIKit

class ProductionCollectionView: HorizontalCollectionView {
    
    init() {
        super.init()
        register(ProductionCell.self, forCellWithReuseIdentifier: ProductionCell.identifier)
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension ProductionCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductionCell.identifier, for: indexPath)
        
        return cell
    }
    
    
}
