// Created by Alex Yaro on 2023-02-19.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class HomeViewModelTests: XCTestCase {

    func testOutputs_sections_loadState() {
        let recentActivity = TestPublisher<[ContentObject], Error>()
        let spotlightEntries = TestPublisher<[SpotlightEntryModel], Error>()

        let viewModel = HomeViewModel(dependencies: .init(
            accountDataService: MockAccountDataService(
                recentActivityPublisher: recentActivity.eraseToAnyPublisher()
            ),
            contentService: MockContentService(
                spotlightEntriesPublisher: spotlightEntries.eraseToAnyPublisher()
            ),
            scheduler: .immediate,
            calendar: .current,
            now: Date.init
        ))

        let viewDidAppear = PassthroughRelay<Void>()

        let outputs = viewModel.bind(inputs: .init(
            viewDidAppear: viewDidAppear.eraseToAnyPublisher(),
            tappedReloadButton: .never()
        ))

        let loadStateSubscriber = TestSubscriber.subscribe(to: outputs.loadState)
        let sectionsSubscriber = TestSubscriber.subscribe(to: outputs.sections)

        XCTAssertEqual(loadStateSubscriber.pollValues(), [.initial])
        XCTAssertEqual(sectionsSubscriber.pollValues(), [])

        viewDidAppear.accept()

        XCTAssertEqual(loadStateSubscriber.pollValues(), [.loading])
        XCTAssertEqual(sectionsSubscriber.pollValues(), [])

        recentActivity.send([.song(FakeSongs.loveMusic)])
        spotlightEntries.send([.generic(title: "Test Section", content: [.album(FakeAlbums.catchTheseVibes)])])

        XCTAssertEqual(loadStateSubscriber.pollValues(), [.loaded])
        XCTAssertEqual(sectionsSubscriber.pollValues(), [
            [
                .navigationHeader,
                .recentActivity([.init(from: .song(FakeSongs.loveMusic))]),
                .generic(title: "Test Section", contentTiles: [.init(from: .album(FakeAlbums.catchTheseVibes))])
            ]
        ])
    }

    func testOutputs_sections_loadState_withErrorRecovery() {
        let spotlightEntries = TestPublisher<[SpotlightEntryModel], Error>()

        let viewModel = HomeViewModel(dependencies: .init(
            accountDataService: MockAccountDataService(),
            contentService: MockContentService(
                spotlightEntriesPublisher: spotlightEntries.eraseToAnyPublisher()
            ),
            scheduler: .immediate,
            calendar: .current,
            now: Date.init
        ))

        let viewDidAppearRelay = PassthroughRelay<Void>()
        let reloadButtonRelay = PassthroughRelay<Void>()

        let outputs = viewModel.bind(inputs: .init(
            viewDidAppear: viewDidAppearRelay.eraseToAnyPublisher(),
            tappedReloadButton: reloadButtonRelay.eraseToAnyPublisher()
        ))

        let loadStateSubscriber = TestSubscriber.subscribe(to: outputs.loadState)
        let sectionsSubscriber = TestSubscriber.subscribe(to: outputs.sections)

        XCTAssertEqual(loadStateSubscriber.pollValues(), [.initial])
        XCTAssertEqual(sectionsSubscriber.pollValues(), [])

        viewDidAppearRelay.accept()
        spotlightEntries.send(completion: .failure(GenericError(message: "oh no")))

        XCTAssertEqual(loadStateSubscriber.pollValues(), [.loading, .error(.failedToLoad)])

        viewDidAppearRelay.accept()
        spotlightEntries.send(completion: .failure(GenericError(message: "oh no again")))

        XCTAssertEqual(loadStateSubscriber.pollValues(), [.loading, .error(.failedToLoad)])

        reloadButtonRelay.accept()
        spotlightEntries.send([.moreLike(user: FakeUsers.alexYaro, content: [.playlist(FakePlaylists.vibey)])])

        XCTAssertEqual(loadStateSubscriber.pollValues(), [.loading, .loaded])
        XCTAssertEqual(sectionsSubscriber.pollValues(), [
            [
                .navigationHeader,
                .moreLike(
                    headerViewModel: .init(from: FakeUsers.alexYaro, captionText: "More like"),
                    contentTiles: [
                        .init(from: .playlist(FakePlaylists.vibey))
                    ]
                )
            ]
        ])
    }

    func testOutputs_navBarTitle_backgroundTint() {
        var hourOfDay: Int = 0

        let viewModel = HomeViewModel(dependencies: .init(
            accountDataService: MockAccountDataService(),
            contentService: MockContentService(),
            scheduler: .immediate,
            calendar: .testCalendar,
            now: {
                Calendar.testCalendar.date(from: DateComponents(
                    year: 2023,
                    month: 3,
                    day: 19,
                    hour: hourOfDay
                ))!
            }
        ))

        let viewDidAppearRelay = PassthroughRelay<Void>()

        let outputs = viewModel.bind(inputs: .init(
            viewDidAppear: viewDidAppearRelay.eraseToAnyPublisher(),
            tappedReloadButton: .never()
        ))

        let navigationHeaderTitle = TestSubscriber.subscribe(to: outputs.navigationHeaderTitle)
        let backgroundTintStyle = TestSubscriber.subscribe(to: outputs.backgroundTintStyle)

        XCTAssertEqual(navigationHeaderTitle.pollValues(), [])
        XCTAssertEqual(backgroundTintStyle.pollValues(), [])

        viewDidAppearRelay.accept()

        XCTAssertEqual(navigationHeaderTitle.pollValues(), ["Good night"])
        XCTAssertEqual(backgroundTintStyle.pollValues(), [.night])

        hourOfDay = 5
        viewDidAppearRelay.accept()

        XCTAssertEqual(navigationHeaderTitle.pollValues(), ["Good morning"])
        XCTAssertEqual(backgroundTintStyle.pollValues(), [.morning])

        hourOfDay = 12
        viewDidAppearRelay.accept()

        XCTAssertEqual(navigationHeaderTitle.pollValues(), ["Good afternoon"])
        XCTAssertEqual(backgroundTintStyle.pollValues(), [.afternoon])

        hourOfDay = 18
        viewDidAppearRelay.accept()

        XCTAssertEqual(navigationHeaderTitle.pollValues(), ["Good evening"])
        XCTAssertEqual(backgroundTintStyle.pollValues(), [.evening])

        viewDidAppearRelay.accept()

        // should not re-emit duplicate values
        XCTAssertEqual(navigationHeaderTitle.pollValues(), [])
        XCTAssertEqual(backgroundTintStyle.pollValues(), [])
    }
}
