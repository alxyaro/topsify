//
//  HomeViewModel.swift
//  Topsify
//
//  Created by Alex Yaro on 2022-05-02.
//

import Foundation
import Combine
import CombineExt
import CombineSchedulers
import UIKit

struct HomeViewModel {
    private let dependencies: Dependencies

    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }

    func bind(inputs: Inputs) -> Outputs {
        let reloadTrigger = inputs.viewDidAppear
            .throttle(for: .seconds(60 * 5), scheduler: dependencies.scheduler, latest: false)
            .merge(with: inputs.tappedReloadButton)
            .share()

        let fetchRecentActivity = {
            dependencies.service.fetchRecentActivity()
                .replaceError(with: [])
                .setFailureType(to: HomeError.self)
        }

        let fetchSpotlight = {
            dependencies.service.fetchSpotlightEntries()
                .mapError(HomeError.failedToLoad)
        }

        let tappedContentSubject = PassthroughSubject<ContentID, Never>()

        let (sections, loadState) = reloadTrigger
            .dataWithLoadState {
                Publishers.combineLatest(
                    fetchRecentActivity(),
                    fetchSpotlight()
                )
                .map { recentActivity, spotlight in
                    var result = [Section]()
                    result.append(.navigationHeader)
                    if !recentActivity.isEmpty {
                        result.append(.recentActivity(recentActivity.map { RecentActivityItemViewModel(from: $0) }))
                    }
                    result.append(contentsOf: spotlight.map { Section(from: $0, tappedContentSubject: tappedContentSubject) })
                    return result
                }
            }

        let backgroundTintStyle = inputs.viewDidAppear
            .map { _ -> BackgroundTintStyle in
                let hour = dependencies.calendar.component(.hour, from: dependencies.now())

                if hour < 5 {
                    return .night
                } else if hour < 12 {
                    return .morning
                } else if hour < 18 {
                    return .afternoon
                } else {
                    return .evening
                }
            }
            .removeDuplicates()

        let navigationHeaderTitle = backgroundTintStyle
            .map {
                switch $0 {
                case .night:
                    return NSLocalizedString("Good night", comment: "Nav bar title for night time")
                case .morning:
                    return NSLocalizedString("Good morning", comment: "Nav bar title for morning time")
                case .afternoon:
                    return NSLocalizedString("Good afternoon", comment: "Nav bar title for afternoon time")
                case .evening:
                    return NSLocalizedString("Good evening", comment: "Nav bar title for evening time")
                }
            }

        return Outputs(
            loadState: loadState,
            navigationHeaderTitle: navigationHeaderTitle.eraseToAnyPublisher(),
            backgroundTintStyle: backgroundTintStyle.eraseToAnyPublisher(),
            sections: sections
        )
    }
}

// MARK: - Nested Types

extension HomeViewModel {

    struct Inputs {
        let viewDidAppear: AnyPublisher<Void, Never>
        let tappedReloadButton: AnyPublisher<Void, Never>
    }

    struct Outputs {
        let loadState: AnyPublisher<LoadState<HomeError>, Never>
        let navigationHeaderTitle: AnyPublisher<String, Never>
        let backgroundTintStyle: AnyPublisher<BackgroundTintStyle, Never>
        let sections: AnyPublisher<[Section], Never>
    }

    struct Dependencies {
        let service: HomeServiceType
        let scheduler: AnySchedulerOfDQ
        let calendar: Calendar
        let now: () -> Date
    }

    enum HomeError: UserFacingError {
        case failedToLoad

        var message: String {
            switch self {
            case .failedToLoad:
                return NSLocalizedString("Failed to load the homescreen content.", comment: "Homescreen error description")
            }
        }
    }

    enum Section: Equatable {
        case navigationHeader
        case recentActivity([RecentActivityItemViewModel])
        case generic(header: String, contentTiles: [ContentTileViewModel])
        case moreLike(headerViewModel: ArtistHeaderViewModel, contentTiles: [ContentTileViewModel])
    }

    struct ArtistHeaderViewModel: Equatable {
        let avatarURL: URL
        let artistName: String
        let captionText: String

        @IgnoreEquality private(set) var onTap: () -> Void
    }

    enum BackgroundTintStyle {
        case night
        case morning
        case afternoon
        case evening
    }
}

// MARK: - Model Conversion

private extension HomeViewModel.Section {

    init(
        from spotlightEntry: SpotlightEntry,
        tappedContentSubject: some Subject<ContentID, Never>
    ) {
        switch spotlightEntry {
        case .generic(let generic):
            self = .generic(
                header: generic.title,
                contentTiles: generic.items.map { ContentTileViewModel(from: $0, tappedContentSubject: tappedContentSubject) }
            )
        case .moreLike(let moreLike):
            self = .moreLike(
                headerViewModel: HomeViewModel.ArtistHeaderViewModel(
                    from: moreLike.artist,
                    caption: NSLocalizedString("More like", comment: "Precedes an artist's name, e.g. 'More like - Post Malone'"),
                    tappedContentSubject: tappedContentSubject
                ),
                contentTiles: moreLike.items.map { ContentTileViewModel(from: $0, tappedContentSubject: tappedContentSubject) }
            )
        }
    }
}

private extension RecentActivityItemViewModel {

    init(from model: RecentActivityItem) {
        title = model.title
        imageURL = model.imageURL
    }
}

private extension ContentTileViewModel {

    init(
        from contentItem: SpotlightEntry.ContentItem,
        tappedContentSubject: some Subject<ContentID, Never>
    ) {
        self.init(
            imageURL: contentItem.imageURL,
            title: contentItem.title,
            subtitle: contentItem.subtitle,
            isCircular: contentItem.contentID.contentType == .artist,
            onTap: {
                tappedContentSubject.send(contentItem.contentID)
            }
        )
    }
}

private extension HomeViewModel.ArtistHeaderViewModel {

    init(
        from artistRef: ArtistRef,
        caption: String,
        tappedContentSubject: some Subject<ContentID, Never>
    ) {
        self.init(
            avatarURL: artistRef.avatarURL,
            artistName: artistRef.name,
            captionText: caption,
            onTap: {
                tappedContentSubject.send(ContentID(contentType: .artist, id: artistRef.id))
            }
        )
    }
}
