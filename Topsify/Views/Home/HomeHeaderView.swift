//
//  HomeHeaderView.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-06.
//

import UIKit

class HomeHeaderView: UIView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 21, weight: .bold)
        label.numberOfLines = 1
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        
        
    }
    required init(coder: NSCoder) {
        fatalError()
    }
    
    private func layoutHeading() {
        
    }
    
    
}
