// Created by Alex Yaro on 2023-08-30.

import Combine
import UIKit

// TODO: rename to AppNavigationController
final class NewAppNavigationController: UINavigationController {

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        delegate = self
        interactivePopGestureRecognizer?.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    private func setUpTopBarIfNeeded(
        for viewController: UIViewController,
        topBarConfiguring: TopBarConfiguring,
        withBackButton: Bool
    ) {
        guard !viewController.view.subviews.contains(where: { $0 is TopBar }) else {
            return
        }

        var backButtonVisibility = TopBar.BackButtonVisibility.hidden
        if withBackButton {
            backButtonVisibility = .shown { [weak self] in
                self?.popViewController(viewController, animated: true)
            }
        }

        let topBar = TopBar(
            configurator: topBarConfiguring,
            backButtonVisibility: backButtonVisibility
        )

        viewController.view.addSubview(topBar)
        viewController.additionalSafeAreaInsets.top = TopBar.safeAreaHeight
        topBar.constrainEdgesToSuperview(excluding: .bottom)
        topBar.bottomAnchor.constraint(equalTo: viewController.view.safeAreaLayoutGuide.topAnchor).isActive = true

        if let playButton = topBarConfiguring.topBarPlayButton {
            viewController.view.addSubview(playButton)
        }
    }
}

extension NewAppNavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        let hideNavigationBar = viewController is TopBarConfiguring || viewController is NavigationHeaderProviding

        // Note: This delegate method is called after viewDidLoad/viewWillAppear, so this would override VC
        // visibility preference of the native navbar. In the future, we may want to have a regular VC
        // that hides the native navbar.
        setNavigationBarHidden(hideNavigationBar, animated: animated)

        if let topBarConfiguring = viewController as? TopBarConfiguring {
            setUpTopBarIfNeeded(
                for: viewController,
                topBarConfiguring: topBarConfiguring,
                withBackButton: viewControllers.firstIndex(of: viewController) != 0
            )
        }
    }
}

/// Used for the delegate of `interactivePopGestureRecognizer` to enable the
/// pop gesture even when the native navigation bar is hidden.
extension NewAppNavigationController: UIGestureRecognizerDelegate {

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        viewControllers.count > 1
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
