// Created by Alex Yaro on 2023-08-16.

import Combine
import Foundation

final class AlbumViewModel {
    private let albumID: UUID
    private let dependencies: Dependencies

    init(
        albumID: UUID,
        dependencies: Dependencies
    ) {
        self.albumID = albumID
        self.dependencies = dependencies
    }

    func bind(inputs: Inputs) -> Outputs {

        let (data, loadState) = inputs.reloadRequested
            .prepend(())
            .dataWithLoadState { [dependencies, albumID] in
                Publishers.CombineLatest(
                    dependencies.contentService.fetchAlbum(withID: albumID),
                    dependencies.contentService.fetchSongs(forAlbumID: albumID)
                )
                .map { (album: $0.0, songs: $0.1) }
                .mapError {
                    switch $0 {
                    case .notFound:
                        return LoadError.albumNotFound
                    case .generic:
                        return LoadError.failedToLoad
                    }
                }
            }

        let album = data.map(\.album)
        let albumSongs = data.map(\.songs)

        return Outputs(
            loadState: loadState.eraseToAnyPublisher(),
            bannerViewModel: album
                .map { [dependencies] in
                    ArtworkBannerViewModel(
                        album: $0,
                        dependencies: .init(calendar: dependencies.calendar)
                    )
                }
                .eraseToAnyPublisher(),
            songListViewModels: albumSongs
                .map { songs in
                    songs.map { song in
                        SongListCellViewModel(song: song)
                    }
                }
                .eraseToAnyPublisher()
        )
    }
}

// MARK: - Nested Types

extension AlbumViewModel {

    struct Dependencies {
        let calendar: Calendar
        let contentService: ContentServiceType
    }

    struct Inputs {
        let reloadRequested: AnyPublisher<Void, Never>
    }

    struct Outputs {
        let loadState: AnyPublisher<LoadState<LoadError>, Never>
        let bannerViewModel: AnyPublisher<ArtworkBannerViewModel, Never>
        let songListViewModels: AnyPublisher<[SongListCellViewModel], Never>
    }

    enum LoadError: UserFacingError {
        case albumNotFound
        case failedToLoad

        var message: String {
            switch self {
            case .albumNotFound:
                return NSLocalizedString("The album you were looking for could not be found.", comment: "Error message")
            case .failedToLoad:
                return NSLocalizedString("Couldn't fetch the album, please try again later.", comment: "Error message")
            }
        }
    }
}

// MARK: - Live Dependencies

extension AlbumViewModel.Dependencies {

    static func live() -> Self {
        .init(
            calendar: .current,
            contentService: ContentService()
        )
    }
}

// MARK: - Localized Strings

private extension String {
    static let albumNotFound = NSLocalizedString("The album you were looking for could not be found.", comment: "Error message")
    static let couldNotFetchAlbum = NSLocalizedString("Couldn't fetch the album, please try again later.", comment: "Error message")
}
