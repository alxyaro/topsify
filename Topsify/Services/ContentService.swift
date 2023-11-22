// Created by Alex Yaro on 2023-02-05.

import Combine
import Foundation

protocol ContentServiceType {
    func fetchAlbum(id: UUID) -> Future<Album, ContentServiceFetchError>
    func fetchAlbumSongs(albumID id: UUID) -> Future<[Song], ContentServiceFetchError>
    func streamPlaylist(id: UUID) -> AnyPublisher<Playlist, ContentServiceFetchError>
    func streamPlaylistSongs(playlistID id: UUID) -> AnyPublisher<[Song], ContentServiceFetchError>
    func fetchArtist(id: UUID) -> Future<Artist, ContentServiceFetchError>
}

enum ContentServiceFetchError: Error {
    case notFound
    case generic
}

typealias DefaultContentService = FakeContentService
