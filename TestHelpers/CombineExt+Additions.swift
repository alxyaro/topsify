// Created by Alex Yaro on 2023-03-12.

import CombineExt

public extension Event {
    var value: Output? {
        if case let .value(value) = self {
            return value
        }
        return nil
    }
}
