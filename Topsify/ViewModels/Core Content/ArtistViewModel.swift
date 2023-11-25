// Created by Alex Yaro on 2023-10-29.

import Combine
import Foundation

final class ArtistViewModel {
    private let artistID: UUID
    private let dependencies: Dependencies

    init(
        artistID: UUID,
        dependencies: Dependencies
    ) {
        self.artistID = artistID
        self.dependencies = dependencies
    }

    func bind(inputs: Inputs) -> Outputs {

        let (artist, loadState) = inputs.reloadRequested
            .prepend(())
            .dataWithLoadState { [dependencies, artistID] in
                dependencies.contentService
                    .fetchArtist(id: artistID)
                    .mapError { error -> LoadError in
                        switch error {
                        case .notFound:
                            return .artistNotFound
                        case .generic:
                            return .failedToLoad
                        }
                    }
            }
        
        let bannerViewModel = artist
            .map { artist in
                let monthlyListenersStrFormat = NSLocalizedString("%@ monthly listeners", comment: "Details text for artist page, parameter is the number of listeners")
                let monthlyListenersStr = String(format: monthlyListenersStrFormat, artist.about.monthlyListeners.formattedWithAbbreviation())

                return ProminentBannerViewModel(
                    accentColor: artist.accentColor,
                    backgroundImageURL: artist.avatarURL,
                    title: artist.name,
                    details: .simple(monthlyListenersStr),
                    actionBarViewModel: .init(
                        sideButtons: [
                            .init(buttonType: .follow(isFollowing: false), onTap: {}),
                            .init(buttonType: .options, onTap: {})
                        ],
                        shuffleButtonVisibility: .shown(onTap: {})
                    )
                )
            }

        let popularSongs = artist
            .map { artist in
                artist.popularSongs.map { popularSong in
                    return Identified(
                        id: popularSong.song.id,
                        value: SongViewModel(
                            artworkURL: popularSong.song.imageURL,
                            title: popularSong.song.title,
                            subtitle: popularSong.totalPlays.formatted(),
                            showExplicitTag: popularSong.song.isExplicit,
                            optionsButtonVisibility: .shown(onTap: {})
                        )
                    )
                }
            }

        let popularAlbums = artist
            .map { [dependencies] artist in
                artist.popularAlbums.map { popularAlbum in
                    let subtitleLeadingText = if popularAlbum.isLatestRelease {
                        NSLocalizedString("Latest release", comment: "Subtitle for an album")
                    } else {
                        String(dependencies.calendar.component(.year, from: popularAlbum.album.releaseDate))
                    }

                    return Identified(
                        id: popularAlbum.album.id,
                        value: AlbumRowViewModel(
                            imageURL: popularAlbum.album.imageURL,
                            title: popularAlbum.album.title,
                            subtitle: [subtitleLeadingText, popularAlbum.album.type.displayName].bulletJoined(),
                            onTap: {}
                        )
                    )
                }
            }

        return Outputs(
            loadState: loadState,
            title: artist.map(\.name).eraseToAnyPublisher(),
            accentColor: artist.map(\.accentColor).eraseToAnyPublisher(),
            bannerViewModel: bannerViewModel.eraseToAnyPublisher(),
            popularSongs: popularSongs.eraseToAnyPublisher(),
            popularAlbums: popularAlbums.eraseToAnyPublisher()
        )
    }
}

// MARK: - Nested Types

extension ArtistViewModel {

    struct Dependencies {
        let contentService: ContentServiceType
        let calendar: Calendar
    }

    struct Inputs {
        let reloadRequested: AnyPublisher<Void, Never>
    }

    struct Outputs {
        let loadState: AnyPublisher<LoadState<LoadError>, Never>
        let title: AnyPublisher<String, Never>
        let accentColor: AnyPublisher<HexColor, Never>
        let bannerViewModel: AnyPublisher<ProminentBannerViewModel, Never>
        let popularSongs: AnyPublisher<[Identified<SongViewModel, UUID>], Never>
        let popularAlbums: AnyPublisher<[Identified<AlbumRowViewModel, UUID>], Never>
    }

    enum LoadError: UserFacingError {
        case artistNotFound
        case failedToLoad

        var message: String {
            switch self {
            case .artistNotFound:
                return NSLocalizedString("The artist you were looking for could not be found.", comment: "Error message")
            case .failedToLoad:
                return NSLocalizedString("Couldn't fetch the artist, please try again later.", comment: "Error message")
            }
        }
    }
}

// MARK: - Live Dependencies

extension ArtistViewModel.Dependencies {

    static func live() -> Self {
        .init(
            contentService: DefaultContentService(),
            calendar: .current
        )
    }
}
