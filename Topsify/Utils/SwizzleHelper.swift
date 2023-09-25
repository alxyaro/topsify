// Created by Alex Yaro on 2023-09-25.

import UIKit

final class SwizzleHelper {
    private static var isSwizzlingDone = false

    private init() {}

    static func swizzle() {
        guard !isSwizzlingDone else { return }
        defer { isSwizzlingDone = true }

        swizzle_UIScrollView_touchesShouldCancel()
    }

    /// Swizzles `touchesShouldCancel` of `UIScrollView`.
    ///
    /// The original returns `false` for instances of `UIControl`, which is not favourable for the style of the app.
    /// This is especially important when using `AppCollectionView` with orthogonal scrolling sections via the
    /// compositional layout, as setting `delaysContentTouches` to `false` without ensuring the nested
    /// `UIScrollView`s can always cancel touches via `touchesShouldCancel` will trap horizontal scrolling
    /// if the touch starts on a `UIControl`.
    ///
    private static func swizzle_UIScrollView_touchesShouldCancel() {
        let methodToSwizzle = class_getInstanceMethod(UIScrollView.self, #selector(UIScrollView.touchesShouldCancel(in:)))!
        let methodReplacement = class_getInstanceMethod(SwizzleHelper.self, #selector(swizzled_touchesShouldCancel(in:)))!

        method_setImplementation(methodToSwizzle, method_getImplementation(methodReplacement))
    }

    @objc private func swizzled_touchesShouldCancel(in view: UIView) -> Bool {
        return true
    }
}
