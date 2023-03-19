// Created by Alex Yaro on 2023-02-05.

import Foundation

extension Array {
    subscript(safe index: Int) -> Element? {
        guard index >= 0 && index < count else {
            return nil
        }
        return self[index]
    }

    func contains(where keyPath: KeyPath<Element, Bool>) -> Bool {
        self.contains(where: { $0[keyPath: keyPath] })
    }

    func first(where keyPath: KeyPath<Element, Bool>) -> Element? {
        self.first(where: { $0[keyPath: keyPath] })
    }

    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        self.map { $0[keyPath: keyPath] }
    }
}

extension Array where Element == String {
    func joinedBySpacedDot() -> String {
        self.joined(separator: " \u{00B7} ")
    }
}
