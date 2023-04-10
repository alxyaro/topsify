// Created by Alex Yaro on 2023-02-19.

@testable import Topsify
import Foundation
import Combine
import TestHelpers

public struct MockContentService: ContentServiceType {
    var spotlightEntriesPublisher: AnyPublisher<[SpotlightEntryModel], Error> = .just([])
    var fetchSongs: (ContentObject) -> AnyPublisher<[Song], Error> = { _ in .just([])}

    public func spotlightEntries() -> Future<[SpotlightEntryModel], Error> {
        spotlightEntriesPublisher.toFuture()
    }

    public func fetchSongs(for content: ContentObject) -> Future<[Song], Error> {
        fetchSongs(content).toFuture()
    }
}
