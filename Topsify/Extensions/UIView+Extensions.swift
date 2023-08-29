// Created by Alex Yaro on 2023-08-08.

import UIKit

extension UIView {

    func fadeIn(withDuration duration: TimeInterval = 0.2, completion: ((Bool) -> Void)? = nil) {
        guard isHidden || alpha == 0 else { return }
        if isHidden {
            isHidden = false
            alpha = 0
        }
        UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut]) {
            self.alpha = 1
        } completion: { completed in
            completion?(completed)
        }
    }

    func fadeOut(withDuration duration: TimeInterval = 0.2, completion: ((Bool) -> Void)? = nil) {
        guard UIView.areAnimationsEnabled else {
            alpha = 0
            isHidden = true
            completion?(true)
            return
        }
        guard !isHidden && alpha > 0 else { return }
        UIView.animate(withDuration: duration, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut]) {
            self.alpha = 0
        } completion: { completed in
            /// If a fade-in starts right before the fade-out ends, it's possible UIKit will say the fade-out completed.
            /// To prevent this, the alpha value is also checked, which will be >0 if the fade-in has started.
            if completed && self.alpha == 0 {
                self.isHidden = true
            }
            completion?(completed)
        }
    }
}
