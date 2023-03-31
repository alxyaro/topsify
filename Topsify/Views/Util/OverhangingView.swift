//
//  OverhangingView.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-16.
//

import UIKit

class OverhangingView<InnerView: UIView>: UIView {
    let innerView: InnerView
    
    init(_ innerView: InnerView, overhang: NSDirectionalEdgeInsets) {
        self.innerView = innerView
        
        super.init(frame: .zero)
        
        clipsToBounds = false
        
        addSubview(innerView)
        innerView.translatesAutoresizingMaskIntoConstraints = false
        innerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -overhang.leading).isActive = true
        innerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: overhang.trailing).isActive = true
        innerView.topAnchor.constraint(equalTo: topAnchor, constant: -overhang.top).isActive = true
        innerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: overhang.bottom).isActive = true
    }

    convenience init(_ innerView: InnerView, horizontalOverhang: CGFloat = 0, verticalOverhang: CGFloat = 0) {
        self.init(innerView, overhang: .init(horizontal: horizontalOverhang, vertical: verticalOverhang))
    }

    @available(*, unavailable)
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
