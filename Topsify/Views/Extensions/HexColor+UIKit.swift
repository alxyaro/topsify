// Created by Alex Yaro on 2023-07-04.

import DynamicColor
import UIKit

extension HexColor {
    var uiColor: UIColor {
        .init(hexString: hexString)
    }
}
