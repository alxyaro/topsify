// Created by Alex Yaro on 2023-10-01.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class PlaylistViewModelTests: XCTestCase {

    func testInput_tappedReloadButton_causesReload() {
        var shouldFetchFail = true

        let viewModel = PlaylistViewModel(
            playlistID: UUID(),
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    streamPlaylist: { _ in shouldFetchFail ? .fail(.generic) : .just(.mock()) }
                )
            )
        )

        let tappedReloadButton = TestPublisher<Void, Never>()

        let outputs = viewModel.bind(inputs: .mock(
            reloadRequested: tappedReloadButton.eraseToAnyPublisher()
        ))

        let loadState = TestSubscriber.subscribe(to: outputs.loadState)
        _ = TestSubscriber.subscribe(to: outputs.songListViewModels)

        XCTAssertEqual(loadState.pollValues(), [.initial, .loading, .error(.failedToLoad)])

        shouldFetchFail = false
        tappedReloadButton.send()

        XCTAssertEqual(loadState.pollValues(), [.loading, .loaded])
    }

    func testOutput_loadState_isLoading_afterBind() {
        let playlistPublisher = TestPublisher<Playlist, ContentServiceFetchError>()

        let playlist = Playlist.mock()
        let viewModel = PlaylistViewModel(
            playlistID: playlist.id,
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    streamPlaylist: { _ in playlistPublisher.eraseToAnyPublisher() }
                )
            )
        )

        let outputs = viewModel.bind(inputs: .mock())

        let loadState = TestSubscriber.subscribe(to: outputs.loadState)
        _ = TestSubscriber.subscribe(to: outputs.bannerConfig)

        XCTAssertEqual(loadState.pollValues(), [.initial, .loading])
    }

    func testOutput_loadState_isError_onFetchAlbumErrors() {
        assertLoadState(playlist: .fail(.notFound), playlistSongs: .never(), expected: .error(.playlistNotFound))
        assertLoadState(playlist: .fail(.generic), playlistSongs: .never(), expected: .error(.failedToLoad))
    }

    func testOutput_loadState_isError_onFetchAlbumSongsErrors() {
        assertLoadState(playlist: .never(), playlistSongs: .fail(.notFound), expected: .error(.playlistNotFound))
        assertLoadState(playlist: .never(), playlistSongs: .fail(.generic), expected: .error(.failedToLoad))
    }

    func testOutput_loadState_isLoaded_onSuccessfulFetches() {
        assertLoadState(playlist: .just(.mock()), playlistSongs: .just([]), expected: .loaded)
    }

    func testOutput_title_derivedFromContentServiceResponse() {
        let playlist = Playlist.mock(title: "Evening Drive")
        let viewModel = PlaylistViewModel(
            playlistID: playlist.id,
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    streamPlaylist: { _ in .just(playlist) }
                )
            )
        )

        let outputs = viewModel.bind(inputs: .mock())
        let title = TestSubscriber.subscribe(to: outputs.title)

        XCTAssertEqual(try title.pollOnlyValue(), "Evening Drive")
    }

    func testOutput_accentColor_derivedFromContentServiceResponse() {
        let playlist = Playlist.mock(accentColor: .init("#592c69"))
        let viewModel = PlaylistViewModel(
            playlistID: playlist.id,
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    streamPlaylist: { _ in .just(playlist) }
                )
            )
        )

        let outputs = viewModel.bind(inputs: .mock())
        let accentColor = TestSubscriber.subscribe(to: outputs.accentColor)

        XCTAssertEqual(try accentColor.pollOnlyValue(), playlist.accentColor)
    }


    func testOutput_bannerConfig_whenPlaylistIsNonOfficial_isArtworkType() {
        let playlist = Playlist.mock(
            creator: .mock(avatarURL: .imageMock(id: "fantona"), name: "Music Reviewer"),
            imageURL: .imageMock(id: "artwork"),
            title: "Not Goods",
            isOfficial: false,
            totalDuration: .hours(64) + .minutes(23)
        )

        let viewModel = PlaylistViewModel(
            playlistID: playlist.id,
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    streamPlaylist: { _ in .just(playlist) }
                )
            )
        )

        let outputs = viewModel.bind(inputs: .mock())

        let bannerConfig = TestSubscriber.subscribe(to: outputs.bannerConfig)

        XCTAssertEqual(
            try bannerConfig.pollOnlyValue(),
            .artwork(.init(
                accentColor: playlist.accentColor,
                artworkURL: .imageMock(id: "artwork"),
                title: "Not Goods",
                userAttribution: [
                    BannerUserAttribution(
                        avatarURL: .imageMock(id: "fantona"),
                        name: "Music Reviewer"
                    )
                ],
                details: "Playlist \u{2022} 64h 23m",
                actionBarViewModel: BannerActionBarViewModel(
                    sideButtons: [
                        .init(buttonType: .save, onTap: {}),
                        .init(buttonType: .download, onTap: {}),
                        .init(buttonType: .options, onTap: {})
                    ],
                    shuffleButtonVisibility: .shown(onTap: {})
                )
            ))
        )
    }

    func testOutput_bannerConfig_whenPlaylistIsOfficial_isProminentType() {
        let playlist = Playlist.mock(
            creator: .mock(avatarURL: .imageMock(id: "sopfity"), name: "Sopfity"),
            bannerImageURL: .imageMock(id: "banner"),
            title: "Hot Hits Canada",
            isOfficial: true,
            totalDuration: .hours(1) + .minutes(23)
        )

        let viewModel = PlaylistViewModel(
            playlistID: playlist.id,
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    streamPlaylist: { _ in .just(playlist) }
                )
            )
        )

        let outputs = viewModel.bind(inputs: .mock())

        let bannerConfig = TestSubscriber.subscribe(to: outputs.bannerConfig)

        XCTAssertEqual(
            try bannerConfig.pollOnlyValue(),
            .prominent(.init(
                accentColor: playlist.accentColor,
                backgroundImageURL: .imageMock(id: "banner"),
                title: playlist.title,
                details: .userAttributed(
                    description: playlist.description,
                    attribution: [
                        BannerUserAttribution(
                            avatarURL: .imageMock(id: "sopfity"),
                            name: "Sopfity"
                        )
                    ],
                    details: "1h 23m"
                ),
                actionBarViewModel: BannerActionBarViewModel(
                    sideButtons: [
                        .init(buttonType: .save, onTap: {}),
                        .init(buttonType: .download, onTap: {}),
                        .init(buttonType: .options, onTap: {})
                    ],
                    shuffleButtonVisibility: .shown(onTap: {})
                )
            ))
        )
    }

    func testOutput_songListViewModels_derivedFromContentServiceResponse() {
        let songs = [Song].mock(count: 3)
        let viewModel = PlaylistViewModel(
            playlistID: UUID(),
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    streamPlaylist: { _ in .just(.mock()) },
                    streamPlaylistSongs: { _ in .just(songs) }
                )
            )
        )

        let outputs = viewModel.bind(inputs: .mock())

        let songListViewModels = TestSubscriber.subscribe(to: outputs.songListViewModels)

        XCTAssertEqual(try songListViewModels.pollOnlyValue().count, 3)
    }

    // MARK: - Helpers

    private func assertLoadState(
        playlist: AnyPublisher<Playlist, ContentServiceFetchError>,
        playlistSongs: AnyPublisher<[Song], ContentServiceFetchError>,
        expected: LoadState<PlaylistViewModel.LoadError>,
        line: UInt = #line
    ) {
        let viewModel = PlaylistViewModel(
            playlistID: Playlist.mock().id,
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    streamPlaylist: { _ in playlist },
                    streamPlaylistSongs: { _ in playlistSongs }
                )
            )
        )

        let outputs = viewModel.bind(inputs: .mock())

        let loadState = TestSubscriber.subscribe(to: outputs.loadState)
        _ = TestSubscriber.subscribe(to: outputs.bannerConfig)

        XCTAssertEqual(loadState.pollValues(), [.initial, .loading, expected], line: line)
    }
}

extension PlaylistViewModel.Inputs {

    static func mock(
        reloadRequested: AnyPublisher<Void, Never> = .never()
    ) -> Self {
        .init(reloadRequested: reloadRequested)
    }
}
