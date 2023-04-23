// Created by Alex Yaro on 2023-03-18.

import Combine
import CombineExt
import XCTest

/// Similar to using a `PassthroughSubject`, but this doesn't permanently complete on error,
/// so future subscriptions will not get a failure event if an error was previously sent!
public final class TestPublisher<Output, Failure: Error>: Publisher {
    public typealias Output = Output
    public typealias Failure = Failure

    private var queuedSubscriptions = [Subscription<Output, Failure>]()

    public init() {}

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = Subscription(subscriber: AnySubscriber(subscriber))
        queuedSubscriptions.append(subscription)
        subscriber.receive(subscription: subscription)
    }

    public func send(_ value: Output) {
        queuedSubscriptions.forEach {
            if $0.isReady {
                _ = $0.subscriber.receive(value)
                $0.subscriber.receive(completion: .finished)
            }
        }
        queuedSubscriptions = []
    }

    public func send(failure: Failure) {
        queuedSubscriptions.forEach {
            if $0.isReady {
                $0.subscriber.receive(completion: .failure(failure))
            }
        }
        queuedSubscriptions = []
    }
}

extension TestPublisher where Output == Void {
    public func send() {
        send(())
    }
}

fileprivate class Subscription<Input, Failure: Error>: Combine.Subscription {
    let subscriber: AnySubscriber<Input, Failure>
    var isReady = false

    init(subscriber: AnySubscriber<Input, Failure>) {
        self.subscriber = subscriber
    }

    func request(_ demand: Subscribers.Demand) {
        isReady = demand >= .max(1)
    }

    func cancel() {}
}
