// Created by Alex Yaro on 2023-03-18.

import Combine
import CombineExt
import XCTest

/// Similar to using a `PassthroughSubject`, but this doesn't permanently complete on error,
/// so future subscriptions will not get a failure event if an error was previously sent!
public final class TestPublisher<Output, Failure: Error>: Publisher {
    public typealias Output = Output
    public typealias Failure = Failure

    private var subscriptions = [Subscription<Output, Failure>]()

    public init() {}

    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = Subscription(subscriber: AnySubscriber(subscriber))
        subscription.onCancel = { [weak self, weak subscription] in
            self?.subscriptions.removeAll(where: { $0 === subscription })
        }
        subscriptions.append(subscription)
        subscriber.receive(subscription: subscription)
    }

    public func send(_ value: Output) {
        subscriptions.forEach {
            if $0.totalDemand > 0 {
                $0.totalDemand -= 1
                $0.totalDemand += $0.subscriber.receive(value)
            }
        }
    }

    public func send(completion: Subscribers.Completion<Failure>) {
        subscriptions.forEach {
            $0.subscriber.receive(completion: completion)
        }
        subscriptions = []
    }
}

extension TestPublisher where Output == Void {
    public func send() {
        send(())
    }
}

fileprivate class Subscription<Input, Failure: Error>: Combine.Subscription {
    let subscriber: AnySubscriber<Input, Failure>

    var onCancel: () -> Void = {}
    var totalDemand = Subscribers.Demand.none

    init(subscriber: AnySubscriber<Input, Failure>) {
        self.subscriber = subscriber
    }

    func request(_ demand: Subscribers.Demand) {
        totalDemand += demand
    }

    func cancel() {
        onCancel()
    }
}
