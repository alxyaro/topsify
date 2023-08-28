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
            if completed {
                self.isHidden = true
            }
            completion?(completed)
        }
    }
}
