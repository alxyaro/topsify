//
//  UIViewImplicitlyAnimating+Extensions.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-10-02.
//

import UIKit

extension UIViewImplicitlyAnimating {

    func fade(removing: UIView? = nil, adding: UIView? = nil) {
        slideFade(removing: removing, adding: adding, slideAmount: 0, slideLeft: false)
    }

    func slideFade(removing: UIView? = nil, adding: UIView? = nil, slideAmount: CGFloat, slideLeft: Bool) {
        let slideAmount = slideLeft ? slideAmount : -slideAmount

        if let removing {
            removing.alpha = 1
        }
        if let adding {
            adding.alpha = 0
            adding.frame = adding.frame.offsetBy(dx: slideAmount, dy: 0)
        }

        addAnimations? {
            if let removing {
                removing.alpha = 0
                removing.frame = removing.frame.offsetBy(dx: -slideAmount, dy: 0)
            }
            if let adding {
                adding.alpha = 1
                adding.frame = adding.frame.offsetBy(dx: -slideAmount, dy: 0)
            }
        }
    }

    func transition<T, V>(on object: T, property: ReferenceWritableKeyPath<T, V>, fromValue: V) {
        let newValue = object[keyPath: property]
        object[keyPath: property] = fromValue
        addAnimations? {
            object[keyPath: property] = newValue
        }
    }
}
