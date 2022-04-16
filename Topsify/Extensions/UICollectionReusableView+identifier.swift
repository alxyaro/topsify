//
//  UICollectionReusableView+identifier.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-04.
//

import UIKit

extension UICollectionReusableView {
    class var identifier: String {
        String(describing: Self.self)
    }
}
