// Created by Alex Yaro on 2023-02-05.

import Combine
import Foundation

protocol ContentServiceType {
    func fetchAlbum(withID id: UUID) -> Future<Album, ContentServiceFetchError>
    func fetchSongs(forAlbumID id: UUID) -> Future<[Song], ContentServiceFetchError>
}

enum ContentServiceFetchError: Error {
    case notFound
    case generic
}

typealias DefaultContentService = FakeContentService
