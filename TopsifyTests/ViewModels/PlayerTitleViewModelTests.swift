// Created by Alex Yaro on 2023-04-23.

@testable import Topsify
import Combine
import TestHelpers
import XCTest

final class PlayerTitleViewModelTests: XCTestCase {

    func test_title() {
        let playbackQueue = MockPlaybackQueue()
        let sut = PlayerTitleViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = sut.bind(inputs: ())

        let title = TestSubscriber.subscribe(to: outputs.title)

        XCTAssertEqual(try title.pollOnlyValue(), "")

        playbackQueue.stateValue.activeItem = .init(song: .mock(title: "Ronda"))

        XCTAssertEqual(try title.pollOnlyValue(), "Ronda")
    }

    func test_artists() {
        let playbackQueue = MockPlaybackQueue()
        let sut = PlayerTitleViewModel(dependencies: .init(playbackQueue: playbackQueue))

        let outputs = sut.bind(inputs: ())

        let artists = TestSubscriber.subscribe(to: outputs.artists)

        XCTAssertEqual(try artists.pollOnlyValue(), "")

        playbackQueue.stateValue.activeItem = .init(song: .mock(artists: [.mock(name: "SomeOne"), .mock(name: "Some Two")]))

        XCTAssertEqual(try artists.pollOnlyValue(), "SomeOne, Some Two")
    }
}
