// Created by Alex Yaro on 2023-02-19.

import Combine

protocol AccountDataServiceType {
    func recentActivity() -> Future<[ContentObject], Error>
}

// Simulating live implementation:
typealias AccountDataService = FakeAccountDataService
