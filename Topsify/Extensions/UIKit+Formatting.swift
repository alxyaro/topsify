// Created by Alex Yaro on 2023-11-07.

import Foundation

extension Int {

    // Note: this shadows the iOS 15 formatting function
    @available(iOS, deprecated: 15, message: "Switch to native formatted() API")
    func formatted() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}
