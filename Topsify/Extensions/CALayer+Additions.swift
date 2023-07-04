// Created by Alex Yaro on 2023-03-31.

import QuartzCore

extension CALayer {

    /// The `UIView` counterpart for Core Animation layers. By default, properties of these layers are
    /// automatically animated when changed, and this allows the avoidance of that.
    static func performWithoutAnimation(actions: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        actions()
        CATransaction.commit()
    }

    static func perform(withDuration duration: CFTimeInterval, actions: () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        actions()
        CATransaction.commit()
    }
}
