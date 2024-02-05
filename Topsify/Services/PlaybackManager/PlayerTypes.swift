// Created by Alex Yaro on 2023-12-31.

import Combine
import Foundation
import AVFoundation

/// Thin protocol wrappers over AVFoundation player types.

protocol PlayerItemType: Hashable {
    var status: AVPlayerItem.Status { get }
    var statusPublisher: AnyPublisher<AVPlayerItem.Status, Never> { get }
    var duration: CMTime { get }

    init(url: URL)

    func currentTime() -> CMTime
}


protocol PlayerType {
    associatedtype Item: PlayerItemType

    var status: AVPlayer.Status { get }
    var statusPublisher: AnyPublisher<AVPlayer.Status, Never> { get }
    var currentItem: Item? { get }
    var currentItemPublisher: AnyPublisher<Item?, Never> { get }
    var periodicTimePublisher: AnyPublisher<Void, Never> { get }

    func replaceCurrentItem(with item: Item?)

    @MainActor func play()
    @MainActor func pause()
    @discardableResult func seek(to time: CMTime) async -> Bool
    @discardableResult func seek(
        to time: CMTime,
        toleranceBefore: CMTime,
        toleranceAfter: CMTime
    ) async -> Bool
}

protocol QueuePlayerType: PlayerType {
    func items() -> [Item]
    func advanceToNextItem()
    func insert(_ item: Item, after afterItem: Item?)
    func remove(_ item: Item)
    func removeAllItems()
}

// MARK: - Convenience Helpers

extension PlayerType {

    var currentItemStatusPublisher: AnyPublisher<AVPlayerItem.Status, Never> {
        currentItemPublisher
            .map { $0?.statusPublisher ?? .never() }
            .switchToLatest()
            .eraseToAnyPublisher()
    }
}

// MARK: - Default Conformances

extension AVPlayerItem: PlayerItemType {
    var statusPublisher: AnyPublisher<Status, Never> {
        publisher(for: \.status, options: [.initial, .new]).eraseToAnyPublisher()
    }
}

extension AVPlayer: PlayerType {
    var statusPublisher: AnyPublisher<Status, Never> {
        publisher(for: \.status, options: [.initial, .new]).eraseToAnyPublisher()
    }
    
    var currentItemPublisher: AnyPublisher<AVPlayerItem?, Never> {
        publisher(for: \.currentItem, options: [.initial, .new]).eraseToAnyPublisher()
    }
    
    var periodicTimePublisher: AnyPublisher<Void, Never> {
        periodicTimePublisher(forInterval: CMTime(value: 1, timescale: 5)).mapToVoid().eraseToAnyPublisher()
    }
}

extension AVQueuePlayer: QueuePlayerType {}
