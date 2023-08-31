// Created by Alex Yaro on 2023-07-04.

import DynamicColor
import UIKit

/// A UI framework-independent abstraction on hexadecimal colors.
struct HexColor: Equatable {
    let hexString: String

    init(unchecked hexString: String) {
        self.hexString = hexString
    }

    init(_ hexString: String) {
        self.hexString = DynamicColor(hexString: hexString).toHexString()
    }

    func shaded(by amount: CGFloat) -> Self {
        .init(DynamicColor(hexString: hexString).shaded(amount: amount).toHexString())
    }
}
