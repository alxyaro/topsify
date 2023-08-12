// Created by Alex Yaro on 2023-08-08.

import Combine
import UIKit

final class TopsifyNavigationController: UINavigationController {

    private var currentVCNavBar: TopsifyNavigationBar?

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        navigationBar.isHidden = true
        isNavigationBarHidden = true

        delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    private func makeNavBar(for vc: UIViewController & NavBarConfiguring) -> TopsifyNavigationBar {
        TopsifyNavigationBar(title: vc.title ?? "Untitled Page", configurator: vc)
    }
}

extension TopsifyNavigationController: UINavigationControllerDelegate {

    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let viewController = viewController as? UIViewController & NavBarConfiguring {

            /// Important: the play button must be added to the hierarchy before the nav bar is.
            /// If it's not, the constraints the nav bar creates in relation to the button won't be applied.
            if let playButton = viewController.navBarPlayButton {
                view.addSubview(playButton)
                playButton.useAutoLayout()
                playButton.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -16).isActive = true
            }

            currentVCNavBar?.removeFromSuperview()

            let navBar = makeNavBar(for: viewController)
            view.addSubview(navBar)
            navBar.constrainEdges(to: viewController.view, excluding: .bottom)

            navBar.layoutIfNeeded()
            viewController.additionalSafeAreaInsets.top = max(0, navBar.frame.height - view.safeAreaInsets.top)

            currentVCNavBar = navBar

            /// Ensure the play button is on top of the nav bar.
            if let playButton = viewController.navBarPlayButton {
                view.bringSubviewToFront(playButton)
            }
        }
    }
}
