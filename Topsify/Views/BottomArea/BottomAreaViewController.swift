// Created by Alex Yaro on 2023-06-11.

import Combine
import UIKit

final class BottomAreaViewController: UITabBarController {

    private lazy var customTabBar = TabBarView(
        tabs: [.home, .search, .library],
        activeTabPublisher: activeTabSubject.eraseToAnyPublisher()
    )

    private let playBarView = PlayBarView()

    private let gradientView = CubicGradientView(color: .init(named: "BackgroundColor"))

    private let tabsToVCs: [TabBarView.Tab: UIViewController]
    private let activeTabSubject = CurrentValueSubject<TabBarView.Tab, Never>(.home)
    private var disposeBag = DisposeBag()

    init(
        homeViewController: UIViewController,
        searchViewController: UIViewController,
        libraryViewController: UIViewController
    ) {
        tabsToVCs = [
            .home: homeViewController,
            .search: searchViewController,
            .library: libraryViewController
        ]

        super.init(nibName: nil, bundle: nil)
        delegate = self

        viewControllers = [
            homeViewController,
            searchViewController,
            libraryViewController
        ]

        bindEvents()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tabBar.isHidden = true

        setUpViews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let selectedViewController {
            updateSafeAreaInset(of: selectedViewController)
        }
    }

    private func bindEvents() {
        customTabBar.tabTapPublisher
            .subscribe(activeTabSubject)
            .store(in: &disposeBag)

        activeTabSubject
            .sink { [weak self] tab in
                guard let self, let vc = tabsToVCs[tab], selectedViewController != vc else {
                    return
                }
                updateSafeAreaInset(of: vc)
                selectedViewController = vc
            }
            .store(in: &disposeBag)
    }

    private func setUpViews() {
        gradientView.isUserInteractionEnabled = false

        view.addSubview(gradientView)
        gradientView.constrainEdgesToSuperview(excluding: .top)
        gradientView.heightAnchor.constraint(equalToConstant: 220).isActive = true

        // Empty view to prevent touches (e.g. scrolling) below the nav bar:
        let safeAreaTouchSwallowView = UIView()
        view.addSubview(safeAreaTouchSwallowView)
        safeAreaTouchSwallowView.constrainEdgesToSuperview(excluding: .top)
        safeAreaTouchSwallowView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        view.addSubview(customTabBar)
        customTabBar.constrainEdges(to: view.safeAreaLayoutGuide, excluding: .vertical)
        // Constrain the tab bar such that its bottom padding can extend outside the safe area if there is space:
        customTabBar.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor).isActive = true
        customTabBar.insidePaddingLayoutGuide.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true

        view.addSubview(playBarView)
        playBarView.constrainEdges(to: view.safeAreaLayoutGuide, excluding: .vertical, withInsets: .horizontal(8))
        playBarView.bottomAnchor.constraint(equalTo: customTabBar.topAnchor, constant: -6).isActive = true
    }

    private func updateSafeAreaInset(of viewController: UIViewController) {
        viewController.additionalSafeAreaInsets.bottom = customTabBar.bounds.height + 16
    }
}

extension BottomAreaViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TabTransitionController()
    }
}
