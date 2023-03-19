// Created by Alex Yaro on 2023-03-12.

import Foundation

@propertyWrapper struct IgnoreEquality<T>: Equatable {
    public var wrappedValue: T

    static func == (lhs: IgnoreEquality<T>, rhs: IgnoreEquality<T>) -> Bool {
        true
    }
}
