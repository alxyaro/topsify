// Created by Alex Yaro on 2023-05-28.

import QuartzCore

extension CACornerMask {
    static let topLeft = Self.layerMinXMinYCorner
    static let topRight = Self.layerMaxXMinYCorner
    static let bottomLeft = Self.layerMinXMaxYCorner
    static let bottomRight = Self.layerMaxXMaxYCorner

    static let top: Self = [.topLeft, .topRight]
    static let bottom: Self = [.bottomLeft, .bottomRight]
}
