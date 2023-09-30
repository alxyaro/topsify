// Created by Alex Yaro on 2023-02-05.

import Foundation

extension Collection {

    var isNotEmpty: Bool { !isEmpty }

    subscript(safe index: Index) -> Element? {
        guard index >= self.startIndex && index < self.endIndex else {
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

extension Sequence where Element == String {

    func bulletJoined() -> String {
        filter(\.isNotEmpty).joined(separator: " \u{2022} ")
    }

    func commaJoined() -> String {
        filter(\.isNotEmpty).joined(separator: NSLocalizedString(", ", comment: "List item separator"))
    }
}
