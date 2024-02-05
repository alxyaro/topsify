// Created by Alex Yaro on 2023-11-26.

import AVFoundation
import UIKit

struct RootDependencyContainer {
    private let playbackQueue: any PlaybackQueueType
    private let playbackManager: any PlaybackManagerType

    init() {
        self.playbackQueue = PlaybackQueue()
        self.playbackManager = PlaybackManager(
            player: AVQueuePlayer(),
            playbackQueue: playbackQueue,
            audioSessionHelper: AudioSessionHelper()
        )
    }

    func makeRootViewController() -> UIViewController {
        BottomAreaViewController(
            homeViewController: makeHomeTabViewController(),
            searchViewController: makeSearchTabViewController(),
            libraryViewController: makeLibraryTabViewController(),
            factory: .init(
                playBarView: makePlayBarView(),
                makePlayerViewController: makePlayerViewController
            )
        )
    }

    private func makeHomeTabViewController() -> UIViewController {
        let homeVC = HomeViewController(
            viewModel: .init(
                dependencies: .init(
                    service: DefaultHomeService(),
                    scheduler: .main,
                    calendar: .current,
                    now: Date.init
                )
            ),
            factory: .init(
                makeContentViewController: makeContentViewController(for:)
            )
        )
        return NewAppNavigationController(rootViewController: homeVC)
    }

    private func makeContentViewController(for contentID: ContentID) -> UIViewController? {
        switch contentID.contentType {
        case .album:
            return makeAlbumViewController(albumID: contentID.id)
        case .playlist:
            return makePlaylistViewController(playlistID: contentID.id)
        case .artist:
            return makeArtistViewController(artistID: contentID.id)
        case .user:
            assertionFailure("User VC is not implemented yet!")
            return nil
        }
    }

    private func makeAlbumViewController(albumID: UUID) -> AlbumViewController {
        AlbumViewController(
            viewModel: .init(
                albumID: albumID,
                dependencies: .init(
                    calendar: .current,
                    contentService: DefaultContentService()
                )
            )
        )
    }

    private func makePlaylistViewController(playlistID: UUID) -> PlaylistViewController {
        PlaylistViewController(
            viewModel: .init(
                playlistID: playlistID,
                dependencies: .init(
                    contentService: DefaultContentService()
                )
            )
        )
    }

    private func makeArtistViewController(artistID: UUID) -> ArtistViewController {
        ArtistViewController(
            viewModel: .init(
                artistID: artistID,
                dependencies: .init(
                    contentService: DefaultContentService(),
                    calendar: .current
                )
            )
        )
    }

    private func makeSearchTabViewController() -> UIViewController {
        let temp1 = UIViewController()
        temp1.title = "Search"
        temp1.view.backgroundColor = .yellow
        return temp1
    }

    private func makeLibraryTabViewController() -> UIViewController {
        let temp2 = UIViewController()
        temp2.title = "Library"
        temp2.view.backgroundColor = .cyan
        return temp2
    }

    private func makePlayBarView() -> PlayBarView {
        PlayBarView(
            viewModel: .init(
                dependencies: .init(playbackQueue: playbackQueue)
            )
        )
    }

    private func makePlayerViewController(
        playBarView: PlayBarView,
        interactionControllerForPresentation: UIPercentDrivenInteractiveTransition?
    ) -> PlayerViewController {
        PlayerViewController(
            viewModel: PlayerViewModel(
                dependencies: .init(
                    playbackQueue: playbackQueue,
                    playbackManager: playbackManager
                )
            ),
            playBarView: playBarView,
            interactionControllerForPresentation: interactionControllerForPresentation,
            factory: .init(
                sliderView: makePlayerSliderView(),
                makeQueueViewController: makeQueueViewController
            )
        )
    }

    private func makePlayerSliderView() -> PlayerSliderView {
        PlayerSliderView(
            viewModel: PlayerSliderViewModel(
                dependencies: .init(
                    playbackManager: playbackManager
                )
            )
        )
    }

    private func makeQueueViewController() -> QueueViewController {
        QueueViewController(
            viewModel: .init(
                dependencies: .init(
                    playbackQueue: playbackQueue
                )
            ),
            controlsView: makePlayerControlsView()
        )
    }

    private func makePlayerControlsView() -> PlayerControlsView {
        PlayerControlsView(
            viewModel: .init(
                dependencies: .init(
                    playbackQueue: playbackQueue,
                    playbackManager: playbackManager
                )
            )
        )
    }
}
