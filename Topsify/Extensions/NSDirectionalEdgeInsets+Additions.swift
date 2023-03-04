// Created by Alex Yaro on 2023-03-03.

import UIKit

extension NSDirectionalEdgeInsets {
    static func leading(_ value: CGFloat) -> Self {
        .init(top: 0, leading: value, bottom: 0, trailing: 0)
    }

    static func trailing(_ value: CGFloat) -> Self {
        .init(top: 0, leading: 0, bottom: 0, trailing: value)
    }

    static func top(_ value: CGFloat) -> Self {
        .init(top: value, leading: 0, bottom: 0, trailing: 0)
    }

    static func bottom(_ value: CGFloat) -> Self {
        .init(top: 0, leading: 0, bottom: value, trailing: 0)
    }

    static func + (lhs: Self, rhs: Self) -> Self {
        .init(
            top: lhs.top + rhs.top,
            leading: lhs.leading + rhs.leading,
            bottom: lhs.bottom + rhs.bottom,
            trailing: lhs.trailing + rhs.trailing
        )
    }
}
