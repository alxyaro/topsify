//
//  UIFont+theme.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-04-04.
//

import UIKit

extension UIFont {
    enum AppFontWeight {
        case regular, light, medium, bold, black
    }
    
    class func appFont(ofSize size: CGFloat, weight: AppFontWeight = .regular) -> UIFont {
        var fontName: String
        switch weight {
        case .regular:
            fontName = "Circular Std Book"
        case .light:
            fontName = "Circular Std Light"
        case .medium:
            fontName = "Circular Std Medium"
        case .bold:
            fontName = "Circular Std Bold"
        case .black:
            fontName = "Circular Std Black"
        }
        return UIFont(name: fontName, size: size)!
    }
}
