// Created by Alex Yaro on 2023-07-19.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class SongListCellViewModelTests: XCTestCase {

    func testOutputs_correctlyDerivedFromInitParams() {
        let song = Song.mock(imageURL: .imageMock(), title: "Some song", isExplicit: true)
        let viewModel = SongListCellViewModel(song: song, showOptionsButton: true)

        XCTAssertEqual(viewModel.outputs.artworkURL, song.imageURL)
        XCTAssertEqual(viewModel.outputs.title, song.title)
        XCTAssertEqual(viewModel.outputs.subtitle, song.artists.map(\.name).commaJoined())
        XCTAssertEqual(viewModel.outputs.showExplicitLabel, song.isExplicit)
        XCTAssertEqual(viewModel.outputs.showOptionsButton, true)
    }
}
