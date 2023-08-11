// Created by Alex Yaro on 2023-08-08.

import Combine
import UIKit

final class TopsifyNavigationController: UINavigationController {

    private var currentVCNavBar: TopsifyNavigationBar?

    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        navigationBar.isHidden = true
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
            if let playButton = viewController.navBarPlayButton {
                view.addSubview(playButton)
                playButton.useAutoLayout()
                playButton.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -16).isActive = true
            }
            currentVCNavBar?.removeFromSuperview()
            let navBar = makeNavBar(for: viewController)
            viewController.view.addSubview(navBar)
            navBar.constrainEdges(to: viewController.view, excluding: .bottom)
            currentVCNavBar = navBar
        }
    }
}
