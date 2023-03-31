// Created by Alex Yaro on 2023-03-03.

import UIKit

extension NSDirectionalEdgeInsets {

    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }

    init(uniform value: CGFloat) {
        self.init(top: value, leading: value, bottom: value, trailing: value)
    }

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

    func toNonDirectionalInsets(using trailCollection: UITraitCollection = .current) -> UIEdgeInsets {
        UIEdgeInsets(
            top: top,
            left: trailCollection.layoutDirection == .rightToLeft ? trailing : leading,
            bottom: bottom,
            right: trailCollection.layoutDirection == .rightToLeft ? leading : trailing
        )
    }
}
