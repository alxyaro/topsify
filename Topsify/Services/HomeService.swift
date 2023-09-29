// Created by Alex Yaro on 2023-02-19.

import Combine

protocol HomeServiceType {
    func fetchRecentActivity() -> Future<[RecentActivityItem], HomeServiceFetchError>
    func fetchSpotlightEntries() -> Future<[SpotlightEntry], HomeServiceFetchError>
}

enum HomeServiceFetchError: Error {
    case generic
}

typealias DefaultHomeService = FakeHomeService
