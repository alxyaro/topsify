// Created by Alex Yaro on 2023-08-08.

import Reusable
import UIKit

final class NavigationHeaderView: UIView {
    private static let height: CGFloat = 64

    private let backButton: AppIconButton = {
        let button = AppIconButton(icon: "Icons/chevronLeft", expandedTouchBoundary: .init(uniform: 12))
        button.iconScale = 1.4
        button.isHidden = true
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .appTextPrimary
        label.font = .appFont(ofSize: 21, weight: .bold)
        label.numberOfLines = 1
        return label
    }()

    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 22
        stack.alignment = .center
        return stack
    }()

    var title: String? {
        get {
            titleLabel.text
        }
        set {
            titleLabel.text = newValue
        }
    }

    private var disposeBag = DisposeBag()

    init(buttons: [Button]) {
        super.init(frame: .zero)

        for button in buttons {
            buttonStackView.addArrangedSubview(button)
        }

        let mainStackView = UIStackView(arrangedSubviews: [backButton, titleLabel, SpacerView(), buttonStackView])
        mainStackView.axis = .horizontal
        mainStackView.alignment = .center
        mainStackView.spacing = 8
        mainStackView.directionalLayoutMargins = .horizontal(16)
        mainStackView.isLayoutMarginsRelativeArrangement = true

        addSubview(mainStackView)
        mainStackView.constrainEdgesToSuperview()
        mainStackView.constrainHeight(to: Self.height)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func enableBackButton(handler: @escaping () -> Void) {
        backButton.isHidden = false
        backButton.tapPublisher
            .sink(receiveValue: handler)
            .store(in: &disposeBag)
    }
}

extension NavigationHeaderView {

    class Button: AppIconButton {
        init(icon: String) {
            super.init(icon: icon)
        }
    }
}

extension NavigationHeaderView {

    final class Cell: UICollectionViewCell, Reusable {
        private var headerView: NavigationHeaderView?

        func configure(with headerView: NavigationHeaderView) {
            guard self.headerView !== headerView else {
                return
            }
            self.headerView?.removeFromSuperview()
            self.headerView = headerView
            contentView.addSubview(headerView)
            headerView.constrainEdgesToSuperview(withPriorities: .forCellSizing)
        }
    }
}

extension NavigationHeaderView.Cell {
    static let compositionalLayoutSection: NSCollectionLayoutSection = {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .absolute(NavigationHeaderView.height)
        )
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: size, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)

        return section
    }()
}
