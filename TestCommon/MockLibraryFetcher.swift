// Created by Alex Yaro on 2023-02-19.

@testable import Topsify
import Foundation
import Combine
import TestHelpers

public struct MockLibraryFetcher: LibraryFetching {
    var spotlightEntriesPublisher: AnyPublisher<[SpotlightEntryModel], Error> = .just([])

    public func spotlightEntries() -> Future<[SpotlightEntryModel], Error> {
        spotlightEntriesPublisher.toFuture()
    }
}
