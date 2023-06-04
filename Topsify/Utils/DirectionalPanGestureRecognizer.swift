// Created by Alex Yaro on 2023-03-26.

import UIKit
import UIKit.UIGestureRecognizerSubclass

// Inspired by https://stackoverflow.com/a/30607392
final class DirectionalPanGestureRecognizer: UIPanGestureRecognizer {

    struct Direction: OptionSet {
        let rawValue: Int

        static let up = Self(rawValue: 1 << 0)
        static let down = Self(rawValue: 1 << 1)
        static let left = Self(rawValue: 1 << 2)
        static let right = Self(rawValue: 1 << 3)
    }

    private let direction: Direction

    init(direction: Direction) {
        self.direction = direction
        super.init(target: nil, action: nil)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        if state == .began {
            let velocity = velocity(in: view)
            let isPanningHorizontally = abs(velocity.x) > abs(velocity.y)

            let isGestureAllowed = {
                if isPanningHorizontally {
                    if velocity.x > 0 {
                        return direction.contains(.right)
                    } else {
                        return direction.contains(.left)
                    }
                } else {
                    if velocity.y > 0 {
                        return direction.contains(.down)
                    } else {
                        return direction.contains(.up)
                    }
                }
            }()

            if !isGestureAllowed {
                state = .cancelled
            }
        }
    }
}

