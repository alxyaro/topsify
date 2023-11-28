// Created by Alex Yaro on 2023-06-11.

import Combine
import UIKit

final class BottomAreaViewController: UITabBarController {

    private lazy var customTabBar = TabBarView(
        tabs: [.home, .search, .library],
        activeTabPublisher: activeTabSubject.eraseToAnyPublisher()
    )

    private let playBarView: PlayBarView
    private let playBarPanGestureRecognizer = DirectionalPanGestureRecognizer(direction: .up)
    private let playBarTapGestureRecognizer = UITapGestureRecognizer()

    private var playerTransitionHandler: TransitionPanGestureHandler?

    private let gradientView = GradientFadeView(color: .init(named: "BackgroundColor"), direction: .up)

    private let factory: DependencyFactory
    private let tabsToVCs: [TabBarView.Tab: UIViewController]
    private let activeTabSubject = CurrentValueSubject<TabBarView.Tab, Never>(.home)
    private var disposeBag = DisposeBag()

    init(
        homeViewController: UIViewController,
        searchViewController: UIViewController,
        libraryViewController: UIViewController,
        factory: DependencyFactory
    ) {
        self.factory = factory
        self.playBarView = factory.playBarView

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
        setUpPlayBarGestureRecognizers()
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
        view.backgroundColor = .appBackground

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

    private func setUpPlayBarGestureRecognizers() {
        playBarView.addGestureRecognizer(playBarPanGestureRecognizer)
        playerTransitionHandler = TransitionPanGestureHandler(
            gestureRecognizer: playBarPanGestureRecognizer,
            direction: .up,
            delegate: self
        )

        playBarView.addGestureRecognizer(playBarTapGestureRecognizer)
        playBarTapGestureRecognizer.delegate = self
        playBarTapGestureRecognizer.addTarget(self, action: #selector(presentPlayer))
    }

    @objc private func presentPlayer() {
        let playerVC = factory.makePlayerViewController(playBarView, playerTransitionHandler?.interactionController)
        present(playerVC, animated: true)
    }

    private func updateSafeAreaInset(of viewController: UIViewController) {
        viewController.additionalSafeAreaInsets.bottom = (view.frame.height - playBarView.frame.minY) - view.safeAreaInsets.bottom + 16
    }
}

extension BottomAreaViewController {
    struct DependencyFactory {
        let playBarView: PlayBarView
        let makePlayerViewController: (
            _ playBarView: PlayBarView,
            _ interactionControllerForPresentation: UIPercentDrivenInteractiveTransition?
        ) -> PlayerViewController
    }
}

extension BottomAreaViewController: UITabBarControllerDelegate {

    func tabBarController(_ tabBarController: UITabBarController, animationControllerForTransitionFrom fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return TabTransitionController()
    }
}

extension BottomAreaViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == playBarTapGestureRecognizer {
            return !(touch.view is UIControl)
        }
        return true
    }
}

extension BottomAreaViewController: TransitionPanGestureHandlerDelegate {

    func shouldBeginTransition(_ handler: TransitionPanGestureHandler) -> Bool {
        presentedViewController == nil
    }

    func beginTransition(_ handler: TransitionPanGestureHandler) {
        presentPlayer()
    }

    func completionPanDistance(_ handler: TransitionPanGestureHandler) -> CGFloat {
        // from 0 to the top of the playBar
        playBarView.frame.minY
    }
}
