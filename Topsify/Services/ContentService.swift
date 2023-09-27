// Created by Alex Yaro on 2023-02-05.

import Combine
import Foundation

protocol ContentServiceType {
    func spotlightEntries() -> Future<[SpotlightEntry], Error>
    func fetchAlbum(withID id: UUID) -> Future<Album, ContentServiceErrors.FetchError>
    func fetchSongs(forAlbumID id: UUID) -> Future<[Song], ContentServiceErrors.FetchError>
}

// Simulating live implementation:
typealias ContentService = FakeContentService

// MARK: - Error Types

enum ContentServiceErrors {
    enum FetchError: Error {
        case notFound
        case generic
    }
}
