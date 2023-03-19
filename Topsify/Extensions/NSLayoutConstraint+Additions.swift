//
//  NSLayoutConstraint+Additions.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-04.
//

import UIKit

extension NSLayoutConstraint {
    @discardableResult
    func priority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }

    /// Sets the priority to `justBelowRequired` to fix unsatisfiable constraints spam for `UICollectionViewCell`s
    /// related to `UIView-Encapsulated-Layout`-type constraints.
    @discardableResult
    func fixCellConstraintErrors() -> Self {
        priority(.justLessThanRequired)
    }

    @discardableResult
    func priorityAdjustment(_ adjustment: Float) -> Self {
        self.priority += adjustment
        return self
    }

    @discardableResult
    func isActive(_ active: Bool) -> Self {
        self.isActive = active
        return self
    }

    @discardableResult
    func identifier(_ identifier: String?) -> Self {
        self.identifier = identifier
        return self
    }
}
