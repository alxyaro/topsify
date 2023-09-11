// Created by Alex Yaro on 2023-09-01.

import UIKit

extension UINavigationController {

    /// This helper pops the given view controller and any other controllers above it in the stack,
    /// i.e. showing the view controller that came before it in the stack.
    @discardableResult
    func popViewController(_ viewController: UIViewController, animated: Bool) -> Bool {
        guard
            let targetVCIndex = viewControllers.firstIndex(of: viewController),
            let vcBeforeTargetVC = viewControllers[safe: targetVCIndex - 1]
        else { return false }
        popToViewController(vcBeforeTargetVC, animated: animated)
        return true
    }
}
