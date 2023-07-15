// Created by Alex Yaro on 2023-03-12.

import Combine
import CombineExt
import XCTest

public final class TestSubscriber<Output, Failure: Error>: Subscriber {
    private var subscription: AnyCancellable?
    private var events = [Event<Output, Failure>]()

    public typealias Input = Output

    public enum Error: Swift.Error {
        case tooManyEvents
        case noValue
    }

    deinit {
        subscription?.cancel()
    }

    public func pollEvents() -> [Event<Output, Failure>] {
        let events = self.events
        self.events = []
        return events
    }

    /// A nice shortcut to `pollEvents` if completion event is not expected.
    /// When invoked, this will raise an `XCTFail` if a completion event is found in the queued events.
    public func pollValues(file: StaticString = #file, line: UInt = #line) -> [Output] {
        let events = pollEvents()
        let values = events.compactMap { $0.value }
        if events.count != values.count {
            XCTFail("Expected values only yet completion event is present", file: file, line: line)
        }
        return values
    }

    /// A nice shortcut to `pollValues` if only one value event is expected.
    /// This will throw an error if anything but a single value event is found in the queued events.
    public func pollOnlyValue(file: StaticString = #file, line: UInt = #line) throws -> Output {
        let events = pollEvents()
        if events.count > 1 {
            throw Error.tooManyEvents
        }
        let value = events.lazy.compactMap(\.value).first
        guard let value else {
            throw Error.noValue
        }
        return value
    }

    public func receive(_ input: Input) -> Subscribers.Demand {
        events.append(.value(input))
        return .unlimited
    }

    public func receive(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case .finished:
            events.append(.finished)
        case .failure(let error):
            events.append(.failure(error))
        }
    }

    public func receive(subscription: Subscription) {
        self.subscription = AnyCancellable(subscription)
        subscription.request(.unlimited)
    }
}

extension TestSubscriber {

    // Using "any" instead of "some" as the IDE encounters an internal error when auto-completing this call...
    public static func subscribe(to publisher: any Publisher<Output, Failure>) -> TestSubscriber<Output, Failure> {
        let subscriber = TestSubscriber<Output, Failure>()
        publisher.subscribe(subscriber)
        return subscriber
    }
}
