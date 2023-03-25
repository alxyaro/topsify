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
        label.text = "Good Evening" // TODO: make this time-based
        return label
    }()
    
    let notificationsButton = HeadingButton(iconName: "bell") {
        
    }
    
    let historyButton = HeadingButton(iconName: "clock.arrow.circlepath") {
        
    }
    
    let settingsButton = HeadingButton(iconName: "gear") {
        
    }
    
    init() {
        super.init(frame: .zero)
        
        let buttonStackView = UIStackView(arrangedSubviews: [
            notificationsButton,
            historyButton,
            settingsButton
        ])
        buttonStackView.axis = .horizontal
        buttonStackView.spacing = 15
        buttonStackView.alignment = .center
        
        let mainStackView = UIStackView(arrangedSubviews: [titleLabel, buttonStackView])
        mainStackView.axis = .horizontal
        mainStackView.distribution = .equalSpacing
        mainStackView.alignment = .center
        
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview()
    }
    
    required init(coder: NSCoder) {
        fatalError()
    }
}

class HeadingButton: UIView {
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
        button.constrainEdgesToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleTap() {
        onTap()
    }
}
