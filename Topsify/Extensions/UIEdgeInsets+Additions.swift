// Created by Alex Yaro on 2023-03-31.

import UIKit

extension UIEdgeInsets {

    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    init(uniform value: CGFloat) {
        self.init(horizontal: value, vertical: value)
    }
}
