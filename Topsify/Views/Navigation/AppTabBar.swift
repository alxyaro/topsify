//
//  AppTabBar.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-05-13.
//

import UIKit

class AppTabBar: UIView {
    static let height: CGFloat = 60
    static let gradientExtensionHeight: CGFloat = 30
    
    private let gradientExtensionLayer = CAGradientLayer()
    private let gradientLayer = CAGradientLayer()
    private let solidColorLayer = CALayer()
    let buttons: [AppTabBarButton]
    
    init(buttons: [AppTabBarButton]) {
        self.buttons = buttons
        
        super.init(frame: .zero)
        
        gradientExtensionLayer.colors = [UIColor.appBackground.withAlphaComponent(0).cgColor, UIColor.appBackground.withAlphaComponent(0.4).cgColor, UIColor.appBackground.withAlphaComponent(0.6).cgColor]
        gradientExtensionLayer.locations = [0, 0.5, 1]
        layer.addSublayer(gradientExtensionLayer)
        gradientLayer.colors = [UIColor.appBackground.withAlphaComponent(0.6).cgColor, UIColor.appBackground.cgColor]
        layer.addSublayer(gradientLayer)
        solidColorLayer.backgroundColor = UIColor.appBackground.cgColor
        layer.addSublayer(solidColorLayer)
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12).isActive = true
        stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12).priorityAdjustment(-1).isActive = true
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.heightAnchor.constraint(equalToConstant: Self.height).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientExtensionLayer.frame = CGRect(x: 0, y: -Self.gradientExtensionHeight, width: layer.bounds.width, height: Self.gradientExtensionHeight)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: layer.bounds.width, height: Self.height)
        solidColorLayer.frame = CGRect(x: 0, y: gradientLayer.frame.maxY, width: layer.bounds.width, height: layer.bounds.height - Self.height)
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }

}
