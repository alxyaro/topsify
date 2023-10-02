// Created by Alex Yaro on 2023-10-01.

import Foundation

extension TimeInterval {

    static func minutes(_ count: Double) -> TimeInterval {
        count * 60
    }

    static func hours(_ count: Double) -> TimeInterval {
        count * 60 * 60
    }
}
