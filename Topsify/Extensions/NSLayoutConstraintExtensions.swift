//
//  NSLayoutConstraint+priority.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-04.
//

import UIKit

extension NSLayoutConstraint {
    
    func priority(_ priority: Float) -> Self {
        self.priority = UILayoutPriority(priority)
        return self
    }
    
    func priorityAdjustment(_ adjustment: Float) -> Self {
        self.priority += adjustment
        return self
    }
    
    func isActive(_ active: Bool) -> Self {
        self.isActive = active
        return self
    }
}
