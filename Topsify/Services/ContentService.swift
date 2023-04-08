// Created by Alex Yaro on 2023-02-05.

import Combine

protocol ContentServiceType {
    func spotlightEntries() -> Future<[SpotlightEntryModel], Error>
}

// Simulating live implementation:
typealias ContentService = FakeContentService
