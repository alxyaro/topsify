// Created by Alex Yaro on 2023-02-20.

import UIKit

extension UIColor {
    @available(swift, deprecated: 5.9, message: "Use the new asset catalog static properties in Xcode 15!")
    convenience init(named name: StaticString) {
        self.init(named: "\(name)")!
    }
}
