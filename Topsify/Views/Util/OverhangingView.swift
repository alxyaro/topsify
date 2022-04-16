//
//  OverhangingView.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-16.
//

import UIKit

class OverhangingView<InnerView: UIView>: UIView {
    let horizontalPadding, verticalPadding: CGFloat
    let innerView: InnerView
    
    init(_ innerView: InnerView, horizontalPadding: CGFloat = 10, verticalPadding: CGFloat = 0) {
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.innerView = innerView
        
        super.init(frame: .zero)
        
        clipsToBounds = false
        
        addSubview(innerView)
        innerView.translatesAutoresizingMaskIntoConstraints = false
        innerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -horizontalPadding).isActive = true
        innerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: horizontalPadding).isActive = true
        innerView.topAnchor.constraint(equalTo: topAnchor, constant: -verticalPadding).isActive = true
        innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: verticalPadding).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        innerView.bounds.contains(point)
    }
}
