// Created by Alex Yaro on 2023-07-04.

import DynamicColor
import UIKit

/// A UI framework-independent abstraction on hexadecimal colors.
struct HexColor: Equatable {
    let hexString: String

    init(_ hexString: String) {
        self.hexString = DynamicColor(hexString: hexString).toHexString()
    }

    init(_ hexString: String, shadedBy shade: CGFloat) {
        self.hexString = DynamicColor(hexString: hexString).shaded(amount: shade).toHexString()
    }
}
