// Created by Alex Yaro on 2023-08-22.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class ArtworkBannerViewModelTests: XCTestCase {

    func testOutputs() {
        let artist = User.mock(
            avatarURL: .imageMock(),
            name: "Oray Xela"
        )

        let album = Album.mock(
            artists: [artist],
            imageURL: .imageMock(),
            title: "Best Album",
            type: .album,
            releaseDate: .testDate(.august, 22, 2024),
            accentColorHex: "#123456"
        )

        let viewModel = createViewModel(album: album)

        let outputs = viewModel.bind(inputs: .mock())

        XCTAssertEqual(outputs.accentColor, .init(album.accentColorHex))
        XCTAssertEqual(outputs.artworkURL, album.imageURL)
        XCTAssertEqual(outputs.title, album.title)
        XCTAssertEqual(outputs.userInfo, [.init(avatarURL: artist.avatarURL, name: artist.name)])
        XCTAssertEqual(outputs.details, "Album \u{2022} 2024")
    }

    func testOutput_details_forSingleTypeAlbum() {
        let viewModel = createViewModel(album: .mock(
            type: .single,
            releaseDate: .testDate(.august, 22, 2023)
        ))

        let outputs = viewModel.bind(inputs: .mock())

        XCTAssertEqual(outputs.details, "Single \u{2022} 2023")
    }

    func testOutput_details_forEPTypeAlbum() {
        let viewModel = createViewModel(album: .mock(
            type: .ep,
            releaseDate: .testDate(.august, 22, 2023)
        ))

        let outputs = viewModel.bind(inputs: .mock())

        XCTAssertEqual(outputs.details, "EP \u{2022} 2023")
    }

    private func createViewModel(
        album: Album = .mock()
    ) -> ArtworkBannerViewModel {
        .init(album: album, dependencies: .init(calendar: .testCalendar))
    }
}

extension ArtworkBannerViewModel.Inputs {

    static func mock() -> Self {
        .init()
    }
}
