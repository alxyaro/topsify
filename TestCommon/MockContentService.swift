// Created by Alex Yaro on 2023-02-19.

@testable import Topsify
import Foundation
import Combine
import TestHelpers

struct MockContentService: ContentServiceType {
    var fetchAlbum: (UUID) -> AnyPublisher<Album, ContentServiceFetchError> = { _ in .fail(.notFound) }
    var fetchSongsForAlbum: (UUID) -> AnyPublisher<[Song], ContentServiceFetchError> = { _ in .just([]) }

    func fetchAlbum(withID id: UUID) -> Future<Album, ContentServiceFetchError> {
        fetchAlbum(id).toFuture()
    }

    func fetchSongs(forAlbumID id: UUID) -> Future<[Song], ContentServiceFetchError> {
        fetchSongsForAlbum(id).toFuture()
    }
}
