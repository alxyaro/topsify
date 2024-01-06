// Created by Alex Yaro on 2024-01-01.

import AVFoundation
import Combine

extension AVPlayer {

    func periodicTimePublisher(forInterval interval: CMTime, queue: DispatchQueue = .main) -> AnyPublisher<CMTime, Never> {
        PeriodicTimePublisher(player: self, interval: interval, queue: queue)
            .eraseToAnyPublisher()
    }
}

private extension AVPlayer {

    struct PeriodicTimePublisher: Publisher {
        typealias Output = CMTime
        typealias Failure = Never

        let player: AVPlayer
        let interval: CMTime
        let queue: DispatchQueue

        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, CMTime == S.Input {
            let subscription = PeriodicTimeSubscription(
                subscriber: subscriber,
                player: player,
                interval: interval,
                queue: queue
            )
            subscriber.receive(subscription: subscription)
        }
    }

    class PeriodicTimeSubscription: Subscription {
        var player: AVPlayer?
        var observer: Any?

        init(subscriber: some Subscriber<CMTime, Never>, player: AVPlayer, interval: CMTime, queue: DispatchQueue) {
            self.player = player
            self.observer = player.addPeriodicTimeObserver(forInterval: interval, queue: queue) { time in
                _ = subscriber.receive(time)
            }
        }

        func request(_ demand: Subscribers.Demand) {}

        func cancel() {
            if let observer {
                player?.removeTimeObserver(observer)
            }
            player = nil
            observer = nil
        }
    }
}
