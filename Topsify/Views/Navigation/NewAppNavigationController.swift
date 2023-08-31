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

    private func setUpTopBarIfNeeded(for viewController: UIViewController, topBarConfiguring: TopBarConfiguring) {
        guard !viewController.view.subviews.contains(where: { $0 is TopBar }) else {
            return
        }

        let topBar = TopBar(configurator: topBarConfiguring)

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
        if let topBarConfiguring = viewController as? TopBarConfiguring {
            setNavigationBarHidden(true, animated: animated)
            setUpTopBarIfNeeded(for: viewController, topBarConfiguring: topBarConfiguring)
        } else {
            // Note: This delegate method is called after viewDidLoad/viewWillAppear, so this would override VC
            // visibility preference of the native navbar. In the future, we may want to have a regular VC
            // that hides the native navbar.
            setNavigationBarHidden(false, animated: animated)
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
