//
//  OverhangingView.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-16.
//

import UIKit

class OverhangingView<InnerView: UIView>: UIView {
    let horizontalOverhang, verticalOverhang: CGFloat
    let innerView: InnerView
    
    init(_ innerView: InnerView, horizontalOverhang: CGFloat = 10, verticalOverhang: CGFloat = 0) {
        self.horizontalOverhang = horizontalOverhang
        self.verticalOverhang = verticalOverhang
        self.innerView = innerView
        
        super.init(frame: .zero)
        
        clipsToBounds = false
        
        addSubview(innerView)
        innerView.translatesAutoresizingMaskIntoConstraints = false
        innerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -horizontalOverhang).isActive = true
        innerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: horizontalOverhang).isActive = true
        innerView.topAnchor.constraint(equalTo: topAnchor, constant: -verticalOverhang).isActive = true
        innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: verticalOverhang).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 1) superview will call this first to see if this view should be considered for hitTest()
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        innerView.bounds.contains(convert(point, to: innerView))
    }
    
    // 2) then, this will be called to find the view to hit (always returning innerView would work too)
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        return innerView.hitTest(convert(point, to: innerView), with: event)
    }
}
