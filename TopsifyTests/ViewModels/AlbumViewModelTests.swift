// Created by Alex Yaro on 2023-08-22.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class AlbumViewModelTests: XCTestCase {

    func testInput_tappedReloadButton_causesReload() {
        var shouldFetchFail = true

        let viewModel = AlbumViewModel(
            albumID: .init(),
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    fetchAlbum: { _ in shouldFetchFail ? .fail(.generic) : .just(.mock()) }
                )
            )
        )

        let tappedReloadButton = TestPublisher<Void, Never>()

        let outputs = viewModel.bind(inputs: .mock(
            reloadRequested: tappedReloadButton.eraseToAnyPublisher()
        ))

        let loadState = TestSubscriber.subscribe(to: outputs.loadState)
        let bannerViewModel = TestSubscriber.subscribe(to: outputs.bannerViewModel)
        let songViewModels = TestSubscriber.subscribe(to: outputs.songViewModels)

        XCTAssertEqual(loadState.pollValues(), [.initial, .loading, .error(.failedToLoad)])
        XCTAssertEqual(bannerViewModel.pollValues().count, 0)
        XCTAssertEqual(songViewModels.pollValues().count, 0)

        shouldFetchFail = false
        tappedReloadButton.send()

        XCTAssertEqual(loadState.pollValues(), [.loading, .loaded])
        XCTAssertEqual(bannerViewModel.pollValues().count, 1)
        XCTAssertEqual(songViewModels.pollValues().count, 1)

        tappedReloadButton.send()

        XCTAssertEqual(loadState.pollValues(), [.loading, .loaded])
        XCTAssertEqual(bannerViewModel.pollValues().count, 1)
        XCTAssertEqual(songViewModels.pollValues().count, 1)
    }

    func testOutput_loadState_isLoading_afterBind() {
        let albumPublisher = TestPublisher<Album, ContentServiceFetchError>()

        let album = Album.mock()
        let viewModel = AlbumViewModel(
            albumID: album.id,
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    fetchAlbum: { _ in albumPublisher.eraseToAnyPublisher() }
                )
            )
        )

        let outputs = viewModel.bind(inputs: .mock())

        let loadState = TestSubscriber.subscribe(to: outputs.loadState)
        _ = TestSubscriber.subscribe(to: outputs.bannerViewModel)

        XCTAssertEqual(loadState.pollValues(), [.initial, .loading])
    }

    func testOutput_loadState_isError_onFetchAlbumErrors() {
        assertLoadState(fetchAlbum: .fail(.notFound), fetchAlbumSongs: .never(), expected: .error(.albumNotFound))
        assertLoadState(fetchAlbum: .fail(.generic), fetchAlbumSongs: .never(), expected: .error(.failedToLoad))
    }

    func testOutput_loadState_isError_onFetchAlbumSongsErrors() {
        assertLoadState(fetchAlbum: .never(), fetchAlbumSongs: .fail(.notFound), expected: .error(.albumNotFound))
        assertLoadState(fetchAlbum: .never(), fetchAlbumSongs: .fail(.generic), expected: .error(.failedToLoad))
    }

    func testOutput_loadState_isLoaded_onSuccessfulFetches() {
        assertLoadState(fetchAlbum: .just(.mock()), fetchAlbumSongs: .just([]), expected: .loaded)
    }

    func testOutput_title_derivedFromContentServiceAlbumResponse() {
        let album = Album.mock(title: "Eternal Atake")
        let viewModel = AlbumViewModel(
            albumID: album.id,
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    fetchAlbum: { _ in .just(album) }
                )
            )
        )

        let outputs = viewModel.bind(inputs: .mock())
        let title = TestSubscriber.subscribe(to: outputs.title)

        XCTAssertEqual(try title.pollOnlyValue(), "Eternal Atake")
    }

    func testOutput_accentColor_derivedFromContentServiceAlbumResponse() {
        let album = Album.mock(accentColor: .init("#592c69"))
        let viewModel = AlbumViewModel(
            albumID: album.id,
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    fetchAlbum: { _ in .just(album) }
                )
            )
        )

        let outputs = viewModel.bind(inputs: .mock())
        let accentColor = TestSubscriber.subscribe(to: outputs.accentColor)

        XCTAssertEqual(try accentColor.pollOnlyValue(), album.accentColor)
    }

    func testOutput_bannerViewModel_derivedFromContentServiceResponse() {
        let album = Album.mock(
            artists: [.mock(avatarURL: .imageMock(id: "pnb"), name: "PnB Rock")],
            title: "GTTM: Goin Thru the Motions"
        )

        let viewModel = AlbumViewModel(
            albumID: album.id,
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    fetchAlbum: { _ in .just(album) }
                )
            )
        )

        let outputs = viewModel.bind(inputs: .mock())

        let bannerViewModel = TestSubscriber.subscribe(to: outputs.bannerViewModel)

        let bannerVM = try? bannerViewModel.pollOnlyValue()
        XCTAssertEqual(
            bannerVM,
            .init(
                accentColor: album.accentColor,
                artworkURL: album.imageURL,
                title: album.title,
                description: nil,
                userAttribution: album.artists.map {
                    BannerUserAttribution(
                        avatarURL: $0.avatarURL,
                        name: $0.name
                    )
                },
                details: "Album \u{2022} 2023",
                actionBarViewModel: BannerActionBarViewModel(
                    sideButtons: [
                        .init(buttonType: .save, onTap: {}),
                        .init(buttonType: .download, onTap: {}),
                        .init(buttonType: .options, onTap: {})
                    ],
                    shuffleButtonVisibility: .shown(onTap: {})
                )
            )
        )
    }

    func testOutput_songListViewModels_derivedFromContentServiceResponse() {
        let songs = [Song].mock(count: 3)
        let viewModel = AlbumViewModel(
            albumID: .init(),
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    fetchAlbum: { _ in .just(.mock()) },
                    fetchAlbumSongs: { _ in .just(songs) }
                )
            )
        )

        let outputs = viewModel.bind(inputs: .mock())

        let songViewModels = TestSubscriber.subscribe(to: outputs.songViewModels)

        XCTAssertEqual(try? songViewModels.pollOnlyValue().count, 3)
    }

    // MARK: - Helpers

    private func assertLoadState(
        fetchAlbum: AnyPublisher<Album, ContentServiceFetchError>,
        fetchAlbumSongs: AnyPublisher<[Song], ContentServiceFetchError>,
        expected: LoadState<AlbumViewModel.LoadError>,
        line: UInt = #line
    ) {
        let album = Album.mock()
        let viewModel = AlbumViewModel(
            albumID: album.id,
            dependencies: .init(
                calendar: .testCalendar,
                contentService: MockContentService(
                    fetchAlbum: { _ in fetchAlbum },
                    fetchAlbumSongs: { _ in fetchAlbumSongs }
                )
            )
        )

        let outputs = viewModel.bind(inputs: .mock())

        let loadState = TestSubscriber.subscribe(to: outputs.loadState)
        _ = TestSubscriber.subscribe(to: outputs.bannerViewModel)

        XCTAssertEqual(loadState.pollValues(), [.initial, .loading, expected], line: line)
    }
}

extension AlbumViewModel.Inputs {

    static func mock(
        reloadRequested: AnyPublisher<Void, Never> = .never()
    ) -> Self {
        .init(reloadRequested: reloadRequested)
    }
}
