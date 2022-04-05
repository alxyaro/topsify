//
//  UIViewExtensions.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-03-28.
//

import UIKit

extension UIView {
    
    class func fromNib<T: UIView>() -> T {
        Bundle(for: T.self).loadNibNamed(String(describing: T.self), owner: nil)![0] as! T
    }
}
