// Created by Alex Yaro on 2024-01-01.

import UIKit

enum CustomControlEvent: Int {
    case valueChangedByUser
    case playerSlider_dragValueChanged

    var event: UIControl.Event {
        return UIControl.Event(rawValue: UInt(1 << (24 + rawValue)))
    }
}

extension UIControl.Event {
    static let valueChangedByUser = CustomControlEvent.valueChangedByUser.event
}
