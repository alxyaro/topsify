//
//  HomeRecentListeningActivityItemCell.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-16.
//

import UIKit
import Combine

class HomeRecentListeningActivityItemCell: UICollectionViewCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let label: UILabel = {
        let label = UILabel()
        label.font = .appFont(ofSize: 14, weight: .bold)
        label.textColor = .appTextPrimary
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    var cancellables = [AnyCancellable]()
    var viewModel: HomeRecentListeningActivityItemViewModel? {
        didSet {
            cancellables = []
            label.text = viewModel?.title
            
            viewModel?.$thumbnail.sink(receiveValue: { [unowned self] image in
                UIView.transition(with: imageView, duration: 0.2, options: [.transitionCrossDissolve]) {
                    imageView.image = image
                }
            }).store(in: &cancellables)
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .appCardBackground
        layer.cornerRadius = 5
        clipsToBounds = true
        
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
        
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8).isActive = true
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
