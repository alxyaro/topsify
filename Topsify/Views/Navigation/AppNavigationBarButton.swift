//
//  AppNavigationBarButton.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-10.
//

import UIKit

class AppNavigationBarButton: UIView {
    private let onTap: () -> Void
    
    init(iconName: String, onTap: @escaping () -> Void = {}) {
        self.onTap = onTap
        super.init(frame: .zero)
        
        let button = UIButton(type: .system)
        
        button.setImage(UIImage(systemName: iconName, withConfiguration:
                                    UIImage.SymbolConfiguration(pointSize: 17, weight: .bold)), for: .normal)
        button.tintColor = .appTextPrimary
        button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        
        addSubview(button)
        button.constrain(into: self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleTap() {
        onTap()
    }
}
