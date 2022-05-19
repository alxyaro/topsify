//
//  AppTabBarButton.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-05-13.
//

import UIKit

class AppTabBarButton: AppButton {
    weak var viewController: UIViewController?
    
    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .appFont(ofSize: 12, weight: .regular)
        return label
    }()
    
    override var isSelected: Bool {
        didSet {
            icon.image = isSelected ? viewController?.tabBarItem.selectedImage : viewController?.tabBarItem.image
            icon.tintColor = isSelected ? .appTextPrimary : .appTextSecondary.withAlphaComponent(0.8)
            label.textColor = isSelected ? .appTextPrimary : .appTextSecondary.withAlphaComponent(0.8)
        }
    }

    init(viewController: UIViewController, onTap: AppButton.TapHandler? = nil) {
        self.viewController = viewController
        
        label.text = viewController.title
        
        let stackView = UIStackView(arrangedSubviews: [
            icon,
            label
        ])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.layoutMargins.top = 8
        stackView.layoutMargins.bottom = 8
        
        super.init(contentView: stackView, onTap: onTap)
        
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.widthAnchor.constraint(lessThanOrEqualToConstant: 25).isActive = true
        icon.heightAnchor.constraint(equalTo: icon.widthAnchor).isActive = true
        
        isSelected = isSelected
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
