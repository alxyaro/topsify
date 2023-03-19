// Created by Alex Yaro on 2023-01-29.

import Combine
import CombineExt

typealias DisposeBag = Set<AnyCancellable>

extension Publisher {
    func ignoreFailure() -> AnyPublisher<Output, Never> {
        self.catch { _ in
            Empty(completeImmediately: true)
        }.eraseToAnyPublisher()
    }

    func ignoreCompletion() -> AnyPublisher<Output, Never> {
       ignoreFailure()
            .append(Empty(completeImmediately: false))
            .eraseToAnyPublisher()
    }

    func mapToConstant<C>(_ constant: C) -> AnyPublisher<C, Failure> {
        map { _ in constant }.eraseToAnyPublisher()
    }

    func mapToVoid() -> AnyPublisher<Void, Failure> {
        mapToConstant(())
    }

    func mapOptional() -> AnyPublisher<Output?, Failure> {
        map { Optional($0) }.eraseToAnyPublisher()
    }

    func mapError<E: Error>(_ constant: E) -> AnyPublisher<Output, E> {
        mapError { _ in constant }.eraseToAnyPublisher()
    }

    func assignWeakly<O: AnyObject>(to keyPath: ReferenceWritableKeyPath<O, Output>, on object: O) -> AnyCancellable {
        self.sink(
            receiveCompletion: { _ in },
            receiveValue: { [weak object] output in
                object?[keyPath: keyPath] = output
            }
        )
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

// MARK: - Combine Latest Arity

extension Publishers {
    static func combineLatest<A, B>(_ a: A, _ b: B) -> AnyPublisher<(A.Output, B.Output), A.Failure>
    where A : Publisher, B : Publisher, A.Failure == B.Failure {
        CombineLatest(a, b).eraseToAnyPublisher()
    }

    static func combineLatest<A, B, C>(_ a: A, _ b: B, _ c: C) -> AnyPublisher<(A.Output, B.Output, C.Output), A.Failure>
    where A : Publisher, B : Publisher, C: Publisher, A.Failure == B.Failure, B.Failure == C.Failure {
        CombineLatest3(a, b, c).eraseToAnyPublisher()
    }

    static func combineLatest<A, B, C, D>(_ a: A, _ b: B, _ c: C, _ d: D) -> AnyPublisher<(A.Output, B.Output, C.Output, D.Output), A.Failure>
    where A : Publisher, B : Publisher, C: Publisher, D: Publisher, A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure {
        CombineLatest4(a, b, c, d).eraseToAnyPublisher()
    }

    static func combineLatest<A, B, C, D, E>(_ a: A, _ b: B, _ c: C, _ d: D, _ e: E) -> AnyPublisher<(A.Output, B.Output, C.Output, D.Output, E.Output), A.Failure>
    where A : Publisher, B : Publisher, C: Publisher, D: Publisher, E: Publisher, A.Failure == B.Failure, B.Failure == C.Failure, C.Failure == D.Failure, D.Failure == E.Failure {
        CombineLatest(
            CombineLatest4(a, b, c, d),
            e
        )
        .map { first, second in
            (first.0, first.1, first.2, first.3, second)
        }
        .eraseToAnyPublisher()
    }

    static func combineLatest<T>(_ collection: [T]) -> AnyPublisher<[T.Output], T.Failure> where T: Publisher {
        guard let first = collection.first else {
            return Empty<[T.Output], T.Failure>(completeImmediately: true).eraseToAnyPublisher()
        }
        return first.combineLatest(with: collection[1...]).eraseToAnyPublisher()
    }
}

// MARK: - Load State

extension Publisher where Output == Void, Failure == Never {

    func dataWithLoadState<P: Publisher>(_ fetchData: @escaping () -> P) -> (AnyPublisher<P.Output, Never>, AnyPublisher<LoadState<P.Failure>, Never>) {
        let loadStateRelay = CurrentValueRelay<LoadState<P.Failure>>(.initial)

        let data = self.map {
            loadStateRelay.accept(.loading)
            return fetchData().materialize()
        }
            .switchToLatest()
            .handleEvents(
                receiveOutput: { event in
                    switch event {
                    case .value:
                        loadStateRelay.accept(.loaded)
                    case .failure(let error):
                        loadStateRelay.accept(.error(error))
                    default: break
                    }
                }
            )
            .share()

        return (
            data.values().eraseToAnyPublisher(),
            loadStateRelay.removeDuplicates().eraseToAnyPublisher()
        )
    }
}
