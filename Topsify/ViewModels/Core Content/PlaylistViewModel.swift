// Created by Alex Yaro on 2023-10-01.

import Combine
import Foundation

final class PlaylistViewModel {
    private let playlistID: UUID
    private let dependencies: Dependencies

    init(
        playlistID: UUID,
        dependencies: Dependencies
    ) {
        self.playlistID = playlistID
        self.dependencies = dependencies
    }

    func bind(inputs: Inputs) -> Outputs {

        let (data, loadState) = inputs.reloadRequested
            .prepend(())
            .dataWithLoadState { [dependencies, playlistID] in
                Publishers.CombineLatest(
                    dependencies.contentService.streamPlaylist(id: playlistID),
                    dependencies.contentService.streamPlaylistSongs(playlistID: playlistID)
                )
                .map { (playlist: $0.0, songs: $0.1) }
                .mapError {
                    switch $0 {
                    case .notFound:
                        return LoadError.playlistNotFound
                    case .generic:
                        return LoadError.failedToLoad
                    }
                }
            }

        let playlist = data.map(\.playlist)
        let playlistSongs = data.map(\.songs)

        return Outputs(
            loadState: loadState.eraseToAnyPublisher(),
            title: playlist.map(\.title).eraseToAnyPublisher(),
            accentColor: playlist.map(\.accentColor).eraseToAnyPublisher(),
            bannerViewModel: playlist
                .map { [dependencies] in
                    ArtworkBannerViewModel(
                        from: $0,
                        calendar: dependencies.calendar
                    )
                }
                .removeDuplicates()
                .eraseToAnyPublisher(),
            songListViewModels: playlistSongs
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

extension PlaylistViewModel {

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
        case playlistNotFound
        case failedToLoad

        var message: String {
            switch self {
            case .playlistNotFound:
                return NSLocalizedString("The playlist you were looking for could not be found.", comment: "Error message")
            case .failedToLoad:
                return NSLocalizedString("Couldn't fetch the playlist, please try again later.", comment: "Error message")
            }
        }
    }
}

// MARK: - Private Helpers

private extension ArtworkBannerViewModel {

    init(
        from playlist: Playlist,
        calendar: Calendar
    ) {
        accentColor = playlist.accentColor
        artworkURL = playlist.imageURL
        title = playlist.title
        userInfo = [playlist.creator].map { UserInfo(avatarURL: $0.avatarURL, name: $0.name) }

        let durationFormatter = DateComponentsFormatter()
        durationFormatter.unitsStyle = .abbreviated
        durationFormatter.allowedUnits = [.hour, .minute]
        let durationStr = durationFormatter.string(from: playlist.totalDuration) ?? ""

        let playlistTerm = NSLocalizedString("Playlist", comment: "Content type")
        // TODO: for *owned* playlists, add private/public playlist icons to the details string
        details = [playlistTerm, durationStr].bulletJoined()

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

extension PlaylistViewModel.Dependencies {

    static func live() -> Self {
        .init(
            calendar: .current,
            contentService: DefaultContentService()
        )
    }
}
