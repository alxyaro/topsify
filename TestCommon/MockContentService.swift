// Created by Alex Yaro on 2023-02-19.

@testable import Topsify
import Foundation
import Combine
import TestHelpers

struct MockContentService: ContentServiceType {
    var spotlightEntriesPublisher: AnyPublisher<[SpotlightEntry], Error> = .just([])
    var fetchAlbum: (UUID) -> AnyPublisher<Album, ContentServiceErrors.FetchError> = { _ in .fail(.notFound) }
    var fetchSongsForAlbum: (UUID) -> AnyPublisher<[Song], ContentServiceErrors.FetchError> = { _ in .just([]) }

    func spotlightEntries() -> Future<[SpotlightEntry], Error> {
        spotlightEntriesPublisher.toFuture()
    }

    func fetchAlbum(withID id: UUID) -> Future<Album, ContentServiceErrors.FetchError> {
        fetchAlbum(id).toFuture()
    }

    func fetchSongs(forAlbumID id: UUID) -> Future<[Song], ContentServiceErrors.FetchError> {
        fetchSongsForAlbum(id).toFuture()
    }
}
