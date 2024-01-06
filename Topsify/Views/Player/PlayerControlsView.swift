// Created by Alex Yaro on 2023-03-25.

import UIKit

final class PlayerControlsView: UIView {

    private enum PlayPauseButtonState {
        case play
        case pause

        var icon: String {
            switch self {
            case .play:
                "Icons/playCircle"
            case .pause:
                "Icons/pauseCircle"
            }
        }
    }

    private let shuffleButton = createButton(icon: "Icons/shuffle", scale: 1.2)
    private let previousButton = createButton(icon: "Icons/previous", scale: 1.1)
    private let playPauseButton = createButton(icon: PlayPauseButtonState.play.icon, scale: 2.7)
    private let nextButton = createButton(icon: "Icons/next", scale: 1.1)
    private let repeatButton = createButton(icon: "Icons/repeat", scale: 1.2)

    private let viewModel: PlayerControlsViewModel
    private var playPauseButtonState: PlayPauseButtonState = .play
    private var disposeBag = DisposeBag()

    init(viewModel: PlayerControlsViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupView()
        bindViewModel()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let buttonViews = [
            shuffleButton,
            previousButton,
            playPauseButton,
            nextButton,
            repeatButton
        ]

        let buttonsStackView = UIStackView(arrangedSubviews: buttonViews)
        buttonsStackView.axis = .horizontal
        buttonsStackView.distribution = .equalSpacing
        buttonsStackView.alignment = .center
        buttonsStackView.directionalLayoutMargins = .init(horizontal: PlayerViewConstants.contentSidePadding, vertical: 16)
        buttonsStackView.isLayoutMarginsRelativeArrangement = true

        // In case spacing is tight, we want to arrange subviews for better hit testing
        // (given that we're using the ExpandedTouchView-s)
        buttonsStackView.bringSubviewToFront(previousButton)
        buttonsStackView.bringSubviewToFront(nextButton)
        buttonsStackView.bringSubviewToFront(playPauseButton)

        addSubview(buttonsStackView)
        buttonsStackView.constrainEdgesToSuperview()

        semanticContentAttribute = .playback
    }

    private func bindViewModel() {
        // Using a shared publisher so we're not re-computing playPauseButtonState
        // for the two different inputs. One input may change the value of
        // playPauseButtonState before the second input is processed, therefore,
        // it's important to capture the value of playPauseButtonState right away.
        let tappedPlayPauseButtonPublisher = playPauseButton.tapPublisher
            .compactMap { [weak self] in self?.playPauseButtonState }
            .share()

        let outputs = viewModel.bind(inputs: .init(
            tappedPlayButton: tappedPlayPauseButtonPublisher
                .filter { $0 == .play }
                .mapToVoid()
                .eraseToAnyPublisher(),
            tappedPauseButton: tappedPlayPauseButtonPublisher
                .filter { $0 == .pause }
                .mapToVoid()
                .eraseToAnyPublisher(),
            tappedNextButton: nextButton.tapPublisher,
            tappedPreviousButton: previousButton.tapPublisher
        ))

        outputs.isPlaying
            .sink { [weak self] isPlaying in
                guard let self else { return }
                playPauseButtonState = isPlaying ? .pause : .play
                UIView.performWithoutAnimation {
                    self.playPauseButton.icon = self.playPauseButtonState.icon
                }
            }
            .store(in: &disposeBag)
    }

    private static func createButton(icon: String, scale: CGFloat) -> AppIconButton {
        let button = AppIconButton(icon: icon, expandedTouchBoundary: .init(uniform: 12))
        button.iconScale = scale
        return button
    }
}
