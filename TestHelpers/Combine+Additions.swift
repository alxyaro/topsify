// Created by Alex Yaro on 2023-03-18.

import Combine
import CombineExt
import XCTest

public extension AnyPublisher {

    static func just(_ o: Output) -> AnyPublisher<Output, Failure> {
        Empty<Output, Failure>().prepend(o).eraseToAnyPublisher()
    }

    static func never() -> AnyPublisher<Output, Failure> {
        Empty(completeImmediately: false).eraseToAnyPublisher()
    }
}

public extension Publisher {

    func toFuture(
        file: StaticString = #file,
        line: UInt = #line
    ) -> Future<Output, Failure> {
        Future { promise in
            var cancellable: AnyCancellable?
            cancellable = self.materialize().prefix(1).sink { event in
                switch event {
                case .value(let value):
                    promise(.success(value))
                case .failure(let error):
                    promise(.failure(error))
                case .finished:
                    XCTFail("Publisher finished without value or failure", file: file, line: line)
                }
                cancellable?.cancel()
            }
        }
    }
}

public extension Future {

    static func just(_ o: Output) -> Future<Output, Failure> {
        Future { promise in
            promise(.success(o))
        }
    }

    static func just(_ o: Output) -> Future<Output, Never> {
        Future<Output, Never> { promise in
            promise(.success(o))
        }
    }

    static func error(_ e: Failure) -> Future<Output, Failure> {
        Future { promise in
            promise(.failure(e))
        }
    }
}
