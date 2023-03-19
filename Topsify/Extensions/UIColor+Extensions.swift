// Created by Alex Yaro on 2023-02-20.

import UIKit

extension UIColor {
    convenience init(named name: StaticString) {
        self.init(named: "\(name)")!
    }
}
