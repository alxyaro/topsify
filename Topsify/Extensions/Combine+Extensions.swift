// Created by Alex Yaro on 2023-01-29.

import Combine

extension Publisher {

    func ignoreFailure() -> AnyPublisher<Output, Never> {
        self.catch { _ in
            Empty(completeImmediately: true)
        }.eraseToAnyPublisher()
    }
}

// MARK: - Optional

protocol OptionalType {
    associatedtype WrappedValue
    var wrapped: WrappedValue? { get }
}

extension Optional: OptionalType {
    typealias WrappedValue = Wrapped
    var wrapped: WrappedValue? {
        self
    }
}

extension Publisher where Output: OptionalType {

    func unwrapped() -> AnyPublisher<Output.WrappedValue, Failure> {
        compactMap { $0.wrapped }.eraseToAnyPublisher()
    }
}
