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

extension Publisher where Output: EventConvertible, Failure == Never {
    func mapToLoadState<E: Error & Equatable>() -> AnyPublisher<LoadState<E>, Never> where Output.Failure == E {
        map {
            switch $0.event {
            case .failure(let error):
                return LoadState.error(error)
            default:
                return LoadState.loaded
            }
        }
        .eraseToAnyPublisher()
    }
}

extension Publisher where Failure == Never {
    func mapToCombined<E: Error & Equatable>() -> AnyPublisher<LoadState<E>, Never> where Output == [LoadState<E>] {
        map { $0.combined() }.eraseToAnyPublisher()
    }
}

extension Publishers {
    static func loadStatePublisher<T: Publisher, S: Publisher, F: Error & Equatable>(reloadTrigger: T, sources: [S]) -> AnyPublisher<LoadState<F>, Never>
    where S.Output: EventConvertible, S.Output.Failure == F, S.Failure == Never, T.Failure == Never {
        let values = sources.map { $0.values() }
        let failures = sources.map { $0.failures() }

        return reloadTrigger
            .map { _ in
                Publishers.Merge(
                    Just(LoadState.loading),
                    Publishers.Merge(
                        Publishers.combineLatest(values).map { _ in LoadState.loaded },
                        Publishers.MergeMany(failures).map { LoadState.error($0) }
                    ).prefix(1)
                )
            }
            .switchToLatest()
            .prepend(.initial)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
}
