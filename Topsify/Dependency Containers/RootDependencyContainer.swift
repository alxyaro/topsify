// Created by Alex Yaro on 2023-11-26.

import UIKit

struct RootDependencyContainer {
    private let playbackQueue: any PlaybackQueueType

    init() {
        self.playbackQueue = PlaybackQueue()
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
            )
        )
        return NewAppNavigationController(rootViewController: homeVC)
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
                    playbackQueue: playbackQueue
                )
            ),
            playBarView: playBarView,
            interactionControllerForPresentation: interactionControllerForPresentation,
            factory: .init(
                makeQueueViewController: makeQueueViewController
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
                    playbackQueue: playbackQueue
                )
            )
        )
    }
}
