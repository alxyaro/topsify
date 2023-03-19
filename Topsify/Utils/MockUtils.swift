// Created by Alex Yaro on 2023-02-19.

import Combine
import Foundation

extension Future where Failure == Error {
    /// Creates a mock `Future` that simulates network latency.
    static func simulateLatency(_ result: @autoclosure @escaping () -> Output) -> Future<Output, Error> {
        Future { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(.random(in: 50...1000))) {
                promise(.success(result()))
            }
        }
    }
}
