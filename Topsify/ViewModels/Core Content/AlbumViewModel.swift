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
                    dependencies.contentService.fetchAlbum(id: albumID),
                    dependencies.contentService.fetchAlbumSongs(albumID: albumID)
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
            title: album.map(\.title).eraseToAnyPublisher(),
            accentColor: album.map(\.accentColor).eraseToAnyPublisher(),
            bannerViewModel: album
                .map { [dependencies] in
                    ArtworkBannerViewModel(
                        from: $0,
                        calendar: dependencies.calendar
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
        let title: AnyPublisher<String, Never>
        let accentColor: AnyPublisher<HexColor, Never>
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

// MARK: - Private Helpers

private extension ArtworkBannerViewModel {

    init(
        from album: Album,
        calendar: Calendar
    ) {
        accentColor = album.accentColor
        artworkURL = album.imageURL
        title = album.title
        userAttribution = album.artists.map { BannerUserAttribution(avatarURL: $0.avatarURL, name: $0.name) }

        let releaseYear = String(calendar.component(.year, from: album.releaseDate))
        details = [album.type.displayName, releaseYear].bulletJoined()

        actionBarViewModel = BannerActionBarViewModel(
            sideButtons: [
                .init(buttonType: .save, onTap: {}),
                .init(buttonType: .download, onTap: {}),
                .init(buttonType: .options, onTap: {})
            ],
            shuffleButtonVisibility: .shown(onTap: {})
        )
    }
}

// MARK: - Live Dependencies

extension AlbumViewModel.Dependencies {

    static func live() -> Self {
        .init(
            calendar: .current,
            contentService: DefaultContentService()
        )
    }
}
