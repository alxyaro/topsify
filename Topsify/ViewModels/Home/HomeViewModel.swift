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
            dependencies.accountDataService.recentActivity()
                .replaceError(with: [])
                .setFailureType(to: HomeError.self)
        }

        let fetchSpotlight = {
            dependencies.contentService.spotlightEntries()
                .mapError(HomeError.failedToLoadSpotlight)
        }

        let (sections, loadState) = reloadTrigger
            .dataWithLoadState {
                Publishers.combineLatest(
                    fetchRecentActivity(),
                    fetchSpotlight()
                )
                .map { recentActivity, spotlight in
                    var result = [Section]()
                    if !recentActivity.isEmpty {
                        result.append(.recentActivity(recentActivity.map { RecentActivityItemViewModel(from: $0) }))
                    }
                    result.append(contentsOf: spotlight.map { Section(from: $0) })
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

        let navBarTitle = backgroundTintStyle
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
            navBarTitle: navBarTitle.eraseToAnyPublisher(),
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
        let navBarTitle: AnyPublisher<String, Never>
        let backgroundTintStyle: AnyPublisher<BackgroundTintStyle, Never>
        let sections: AnyPublisher<[Section], Never>
    }

    struct Dependencies {
        let accountDataService: AccountDataServiceType
        let contentService: ContentServiceType
        let scheduler: AnySchedulerOfDQ
        let calendar: Calendar
        let now: () -> Date
    }

    enum HomeError: LocalizedError {
        case failedToLoadSpotlight

        var errorDescription: String? {
            NSLocalizedString("Failed to load the homescreen", comment: "Homescreen error description")
        }

        var failureReason: String? {
            switch self {
            case .failedToLoadSpotlight:
                return NSLocalizedString("The spotlight could not be loaded", comment: "")
            }
        }
    }

    enum Section: Equatable {
        case recentActivity([RecentActivityItemViewModel])
        case generic(title: String, contentTiles: [ContentTileViewModel])
        case moreLike(headerViewModel: HomeArtistHeaderCellViewModel, contentTiles: [ContentTileViewModel])

        init(from model: SpotlightEntryModel) {
            switch model {
            case let .generic(title, content):
                self = .generic(
                    title: title,
                    contentTiles: content.map { ContentTileViewModel(from: $0) }
                )
            case let .moreLike(user, content):
                self = .moreLike(
                    headerViewModel: .init(
                        from: user,
                        captionText: NSLocalizedString("More like", comment: "Text preceeding the name of an artist")
                    ),
                    contentTiles: content.map { ContentTileViewModel(from: $0) }
                )
            }
        }
    }

    enum BackgroundTintStyle {
        case night
        case morning
        case afternoon
        case evening
    }
}

extension HomeViewModel.Dependencies {
    static func live() -> Self {
        .init(
            accountDataService: AccountDataService(),
            contentService: ContentService(),
            scheduler: .main,
            calendar: .current,
            now: Date.init
        )
    }
}
