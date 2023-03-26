// Created by Alex Yaro on 2023-03-26.

import UIKit
import UIKit.UIGestureRecognizerSubclass

// Inspired by https://stackoverflow.com/a/30607392
final class UIAxisPanGestureRecognizer: UIPanGestureRecognizer {
    private let axis: NSLayoutConstraint.Axis

    init(axis: NSLayoutConstraint.Axis) {
        self.axis = axis
        super.init(target: nil, action: nil)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if state == .began {
            let velocity = velocity(in: view)
            switch axis {
            case .horizontal where abs(velocity.x) < abs(velocity.y):
                state = .cancelled
            case .vertical where abs(velocity.y) < abs(velocity.x):
                state = .cancelled
            default:
                break
            }
        }
    }
}

