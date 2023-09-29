// Created by Alex Yaro on 2023-02-19.

@testable import Topsify
import Foundation
import Combine

struct MockHomeService: HomeServiceType {
    var recentActivityPublisher: AnyPublisher<[RecentActivityItem], HomeServiceFetchError> = .just([])
    var spotlightEntriesPublisher: AnyPublisher<[SpotlightEntry], HomeServiceFetchError> = .just([])

    func fetchRecentActivity() -> Future<[RecentActivityItem], HomeServiceFetchError> {
        recentActivityPublisher.toFuture()
    }

    func fetchSpotlightEntries() -> Future<[SpotlightEntry], HomeServiceFetchError> {
        spotlightEntriesPublisher.toFuture()
    }
}
