// Created by Alex Yaro on 2023-03-26.

import UIKit

extension CGRect {

    func expanded(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) -> CGRect {
        let newWidth = max(0, width + left + right)
        let newHeight = max(0, height + top + bottom)
        return CGRect(x: minX - left, y: minY - top, width: newWidth, height: newHeight)
    }

    func expanded(horizontal: CGFloat, vertical: CGFloat) -> CGRect {
        expanded(top: vertical, bottom: vertical, left: horizontal, right: horizontal)
    }

    func expanded(by uniformValue: CGFloat) -> CGRect {
        expanded(top: uniformValue, bottom: uniformValue, left: uniformValue, right: uniformValue)
    }

    func expanded(by insets: UIEdgeInsets) -> CGRect {
        expanded(top: insets.top, bottom: insets.bottom, left: insets.left, right: insets.right)
    }

    mutating func expand(top: CGFloat = 0, bottom: CGFloat = 0, left: CGFloat = 0, right: CGFloat = 0) {
        let newWidth = max(0, width + left + right)
        let newHeight = max(0, height + top + bottom)
        origin.x = minX - left
        origin.y = minY - top
        size.width = newWidth
        size.height = newHeight
    }
}

extension CGSize {

    static func uniform(_ size: CGFloat) -> Self {
        .init(width: size, height: size)
    }
}
