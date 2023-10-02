// Created by Alex Yaro on 2023-02-19.

@testable import Topsify
import Foundation
import Combine
import TestHelpers

struct MockContentService: ContentServiceType {
    var fetchAlbum: (UUID) -> AnyPublisher<Album, ContentServiceFetchError> = { _ in .fail(.notFound) }
    var fetchAlbumSongs: (UUID) -> AnyPublisher<[Song], ContentServiceFetchError> = { _ in .just([]) }
    var streamPlaylist: (UUID) -> AnyPublisher<Playlist, ContentServiceFetchError> = { _ in .fail(.notFound) }
    var streamPlaylistSongs: (UUID) -> AnyPublisher<[Song], ContentServiceFetchError> = { _ in .just([]) }

    func fetchAlbum(id: UUID) -> Future<Album, ContentServiceFetchError> {
        fetchAlbum(id).toFuture()
    }

    func fetchAlbumSongs(albumID id: UUID)  -> Future<[Song], ContentServiceFetchError> {
        fetchAlbumSongs(id).toFuture()
    }

    func streamPlaylist(id: UUID) -> AnyPublisher<Playlist, ContentServiceFetchError> {
        streamPlaylist(id)
    }

    func streamPlaylistSongs(playlistID id: UUID) -> AnyPublisher<[Song], ContentServiceFetchError> {
        streamPlaylistSongs(id)
    }
}
