// Created by Alex Yaro on 2023-02-19.

@testable import Topsify
import XCTest
import TestHelpers
import Combine
import CombineExt

final class HomeViewModelTests: XCTestCase {

    func testOutputs_sections_loadState() {
        let recentActivity = TestPublisher<[RecentActivityItem], HomeServiceFetchError>()
        let spotlightEntries = TestPublisher<[SpotlightEntry], HomeServiceFetchError>()

        let viewModel = HomeViewModel(dependencies: .mock(
            service: MockHomeService(
                recentActivityPublisher: recentActivity.eraseToAnyPublisher(),
                spotlightEntriesPublisher: spotlightEntries.eraseToAnyPublisher()
            )
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

        recentActivity.send([
            .init(
                contentID: ContentID(contentType: .album, id: UUID()),
                imageURL: .imageMock(id: "love_music"),
                title: "Love Music"
            )
        ])
        spotlightEntries.send([
            .generic(.init(
                title: "Generic Section",
                items: [
                    .init(
                        contentID: ContentID(contentType: .playlist, id: UUID()),
                        imageURL: .imageMock(id: "image1"),
                        title: "Going Back in Time",
                        subtitle: "All the songs from early 2000s"
                    )
                ]
            ))
        ])

        XCTAssertEqual(loadStateSubscriber.pollValues(), [.loaded])
        XCTAssertEqual(sectionsSubscriber.pollValues(), [
            [
                .navigationHeader,
                .recentActivity([
                    .init(title: "Love Music", imageURL: .imageMock(id: "love_music"), onTap: {})
                ]),
                .generic(
                    header: "Generic Section",
                    contentTiles: [
                        .init(
                            imageURL: .imageMock(id: "image1"),
                            title: "Going Back in Time",
                            subtitle: "All the songs from early 2000s",
                            isCircular: false,
                            onTap: {}
                        )
                    ]
                )
            ]
        ])
    }

    func testOutputs_sections_loadState_withErrorRecovery() {
        let spotlightEntries = TestPublisher<[SpotlightEntry], HomeServiceFetchError>()

        let viewModel = HomeViewModel(dependencies: .mock(
            service: MockHomeService(
                spotlightEntriesPublisher: spotlightEntries.eraseToAnyPublisher()
            )
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
        spotlightEntries.send(completion: .failure(.generic))

        XCTAssertEqual(loadStateSubscriber.pollValues(), [.loading, .error(.failedToLoad)])

        viewDidAppearRelay.accept()
        spotlightEntries.send(completion: .failure(.generic))

        XCTAssertEqual(loadStateSubscriber.pollValues(), [.loading, .error(.failedToLoad)])

        reloadButtonRelay.accept()
        spotlightEntries.send([
            .moreLike(.init(
                artist: .init(id: UUID(), avatarURL: .imageMock(id: "bnyx"), name: "BNYX"),
                items: [
                    .init(
                        contentID: ContentID(contentType: .artist, id: UUID()),
                        imageURL: .imageMock(id: "trgc"),
                        title: "TRGC",
                        subtitle: "Subtitle goes here"
                    )
                ]
            ))
        ])

        XCTAssertEqual(loadStateSubscriber.pollValues(), [.loading, .loaded])
        XCTAssertEqual(sectionsSubscriber.pollValues(), [
            [
                .navigationHeader,
                .moreLike(
                    headerViewModel: .init(
                        avatarURL: .imageMock(id: "bnyx"),
                        artistName: "BNYX",
                        captionText: "More like",
                        onTap: {}
                    ),
                    contentTiles: [
                        .init(
                            imageURL: .imageMock(id: "trgc"),
                            title: "TRGC",
                            subtitle: "Subtitle goes here",
                            isCircular: true,
                            onTap: {}
                        )
                    ]
                )
            ]
        ])
    }

    func testOutputs_navBarTitle_backgroundTint() {
        var hourOfDay: Int = 0

        let viewModel = HomeViewModel(dependencies: .mock(
            now: { .testDate(.march, 19, 2023, hour: hourOfDay) }
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

    func testOutputs_presentContent_whenContentTileTapped_emitsWithExpectedValue() throws {
        let spotlightEntries = TestPublisher<[SpotlightEntry], HomeServiceFetchError>()

        let viewModel = HomeViewModel(
            dependencies: .mock(
                service: MockHomeService(
                    spotlightEntriesPublisher: spotlightEntries.eraseToAnyPublisher()
                )
            )
        )

        let outputs = viewModel.bind(inputs: .init(
            viewDidAppear: .just(()),
            tappedReloadButton: .never()
        ))

        let sections = TestSubscriber.subscribe(to: outputs.sections)
        let presentContent = TestSubscriber.subscribe(to: outputs.presentContent)

        let contentID = ContentID(contentType: .artist, id: UUID())

        spotlightEntries.send([
            .generic(.init(
                title: "Some Section",
                items: [
                    .init(
                        contentID: contentID,
                        imageURL: .imageMock(),
                        title: "Tory Lanez",
                        subtitle: ""
                    )
                ]
            ))
        ])

        let contentTileTapHandler = try XCTUnwrap({
            for section in try sections.pollOnlyValue() {
                if case let .generic(_, contentTiles) = section {
                    return contentTiles.first?.onTap
                }
            }
            return nil
        }())

        XCTAssertEqual(presentContent.pollValues(), [])

        contentTileTapHandler()

        XCTAssertEqual(presentContent.pollValues(), [contentID])
    }
}

private extension HomeViewModel.Dependencies {

    static func mock(
        service: HomeServiceType = MockHomeService(),
        scheduler:AnySchedulerOfDQ = .immediate,
        calendar: Calendar = .testCalendar,
        now: @escaping () -> Date = { .testDate(.january, 1, 2022) }
    ) -> Self {
        self.init(
            service: service,
            scheduler: scheduler,
            calendar: calendar,
            now: now
        )
    }
}
