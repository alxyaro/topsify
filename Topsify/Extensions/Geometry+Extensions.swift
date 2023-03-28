// Created by Alex Yaro on 2023-03-26.

import UIKit

extension CGRect {

    func expanded(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) -> CGRect {
        Self.init(x: minX - left, y: minY - top, width: width + left + right, height: height + top + bottom)
    }

    func expanded(horizontal: CGFloat, vertical: CGFloat) -> CGRect {
        expanded(top: vertical, bottom: vertical, left: horizontal, right: horizontal)
    }

    func expanded(by uniformValue: CGFloat) -> CGRect {
        expanded(top: uniformValue, bottom: uniformValue, left: uniformValue, right: uniformValue)
    }
}
