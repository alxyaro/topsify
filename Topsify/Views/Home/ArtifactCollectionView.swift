//
//  ProductionCollectionView.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-04.
//

import UIKit

class ArtifactCollectionView: HorizontalCollectionView {
    
    init() {
        super.init()
        register(ArtifactCell.self, forCellWithReuseIdentifier: ArtifactCell.identifier)
        dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

extension ArtifactCollectionView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtifactCell.identifier, for: indexPath)
        
        return cell
    }
    
    
}
