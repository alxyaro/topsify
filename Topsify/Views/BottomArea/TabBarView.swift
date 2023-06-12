// Created by Alex Yaro on 2023-06-11.

import Combine
import UIKit

final class TabBarView: UIView {
    static let verticalPadding: CGFloat = 8

    enum Tab: CaseIterable {
        case home
        case search
        case library

        var icon: UIImage {
            switch self {
            case .home:
                return UIImage(named: "homeIcon")!
            case .search:
                return UIImage(named: "searchIcon")!
            case .library:
                return UIImage(named: "libraryIcon")!
            }
        }

        var activeIcon: UIImage {
            switch self {
            case .home:
                return UIImage(named: "homeActiveIcon")!
            case .search:
                return UIImage(named: "searchActiveIcon")!
            case .library:
                return UIImage(named: "libraryActiveIcon")!
            }
        }

        var title: String {
            switch self {
            case .home:
                return NSLocalizedString("Home", comment: "Tab bar button title")
            case .search:
                return NSLocalizedString("Search", comment: "Tab bar button title")
            case .library:
                return NSLocalizedString("Your Library", comment: "Tab bar button title")
            }
        }
    }

    var tabTapPublisher: AnyPublisher<Tab, Never> {
        Publishers.MergeMany(
            tabButtons
                .map { button in
                    button.tapPublisher.map { button.tab }
                }
        ).eraseToAnyPublisher()
    }

    let insidePaddingLayoutGuide = UILayoutGuide()

    private let tabButtons: [TabButton]
    private var disposeBag = DisposeBag()

    init(
        tabs: [Tab],
        activeTabPublisher: AnyPublisher<Tab, Never>
    ) {
        tabButtons = tabs.map { TabButton(tab: $0) }

        super.init(frame: .zero)

        setUpView()
        bindEvent(activeTabPublisher: activeTabPublisher)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpView() {
        let stackView = UIStackView(arrangedSubviews: tabButtons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill

        addSubview(stackView)
        stackView.constrainEdgesToSuperview(withInsets: .init(horizontal: 4, vertical: 0))

        addLayoutGuide(insidePaddingLayoutGuide)
        insidePaddingLayoutGuide.leadingAnchor.constraint(equalTo: stackView.leadingAnchor).isActive = true
        insidePaddingLayoutGuide.trailingAnchor.constraint(equalTo: stackView.trailingAnchor).isActive = true
        insidePaddingLayoutGuide.topAnchor.constraint(equalTo: stackView.topAnchor, constant: Self.verticalPadding).isActive = true
        insidePaddingLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: -Self.verticalPadding).isActive = true
    }

    private func bindEvent(activeTabPublisher: AnyPublisher<Tab, Never>) {
        activeTabPublisher
            .sink { [tabButtons] tab in
                tabButtons.forEach { button in
                    button.setActive(button.tab == tab)
                }
            }
            .store(in: &disposeBag)
    }
}

private class TabButton: AppButton {

    private let icon: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        icon.constrainDimensions(uniform: 24)
        return icon
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = .appFont(ofSize: 12, weight: .regular)
        return label
    }()

    let tab: TabBarView.Tab

    init(tab: TabBarView.Tab) {
        self.tab = tab

        super.init()

        setupView()
        setActive(false)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let stackView = UIStackView(arrangedSubviews: [icon, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.directionalLayoutMargins = .init(horizontal: 12, vertical: TabBarView.verticalPadding)
        stackView.insetsLayoutMarginsFromSafeArea = false

        contentView.addSubview(stackView)
        stackView.constrainEdgesToSuperview()

        titleLabel.text = tab.title
    }

    func setActive(_ isActive: Bool) {
        icon.image = isActive ? tab.activeIcon : tab.icon

        let color: UIColor = .init(named: isActive ? "Colors/navBarButtonActiveColor" : "Colors/navBarButtonColor")
        icon.tintColor = color
        titleLabel.textColor = color
    }
}
