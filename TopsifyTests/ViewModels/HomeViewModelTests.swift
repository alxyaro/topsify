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
        spotlightEntries.send(failure: GenericError(message: "oh no"))

        XCTAssertEqual(loadStateSubscriber.pollValues(), [.loading, .error(.failedToLoadSpotlight)])

        viewDidAppearRelay.accept()
        spotlightEntries.send(failure: GenericError(message: "oh no again"))

        XCTAssertEqual(loadStateSubscriber.pollValues(), [.loading, .error(.failedToLoadSpotlight)])

        reloadButtonRelay.accept()
        spotlightEntries.send([.moreLike(user: FakeUsers.alexYaro, content: [.playlist(FakePlaylists.vibey)])])

        XCTAssertEqual(loadStateSubscriber.pollValues(), [.loading, .loaded])
        XCTAssertEqual(sectionsSubscriber.pollValues(), [
            [
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

        let navBarTitleSubscriber = TestSubscriber.subscribe(to: outputs.navBarTitle)
        let backgroundTintSubscriber = TestSubscriber.subscribe(to: outputs.backgroundTint)

        XCTAssertEqual(navBarTitleSubscriber.pollValues(), [])
        XCTAssertEqual(backgroundTintSubscriber.pollValues(), [])

        viewDidAppearRelay.accept()

        XCTAssertEqual(navBarTitleSubscriber.pollValues(), ["Good night"])
        XCTAssertEqual(backgroundTintSubscriber.pollValues(), [UIColor(named: "HomeTimeTints/NightColor")])

        hourOfDay = 5
        viewDidAppearRelay.accept()

        XCTAssertEqual(navBarTitleSubscriber.pollValues(), ["Good morning"])
        XCTAssertEqual(backgroundTintSubscriber.pollValues(), [UIColor(named: "HomeTimeTints/MorningColor")])

        hourOfDay = 12
        viewDidAppearRelay.accept()

        XCTAssertEqual(navBarTitleSubscriber.pollValues(), ["Good afternoon"])
        XCTAssertEqual(backgroundTintSubscriber.pollValues(), [UIColor(named: "HomeTimeTints/AfternoonColor")])

        hourOfDay = 18
        viewDidAppearRelay.accept()

        XCTAssertEqual(navBarTitleSubscriber.pollValues(), ["Good evening"])
        XCTAssertEqual(backgroundTintSubscriber.pollValues(), [UIColor(named: "HomeTimeTints/EveningColor")])

        viewDidAppearRelay.accept()

        // should not re-emit duplicate values
        XCTAssertEqual(navBarTitleSubscriber.pollValues(), [])
        XCTAssertEqual(backgroundTintSubscriber.pollValues(), [])
    }
}
