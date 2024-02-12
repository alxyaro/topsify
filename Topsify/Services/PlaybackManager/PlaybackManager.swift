// Created by Alex Yaro on 2023-12-31.

import AVFoundation
import Combine
import Foundation

final class PlaybackManager: PlaybackManagerType {

    var isPlayingPublisher: AnyPublisher<Bool, Never> {
        $isPlaying.eraseToAnyPublisher()
    }

    var timingPublisher: AnyPublisher<PlaybackTiming?, Never> {
        $timing.eraseToAnyPublisher()
    }

    @SubjectBacked var isPlaying = false
    @SubjectBacked var timing: PlaybackTiming?

    private let player: any QueuePlayerType
    private let queuingHelper: QueuePlayerQueuingHelper
    private let playbackQueue: any PlaybackQueueType
    private var audioSessionHelper: AudioSessionHelperType
    private var disposeBag = DisposeBag()

    private var activePlayTaskCancellable: AnyCancellable?
    private var activeSeekTaskCancellable: AnyCancellable?
    private var activeSeekTarget = CurrentValueSubject<CMTime?, Never>(nil)

    init(
        player: any QueuePlayerType,
        playbackQueue: any PlaybackQueueType,
        audioSessionHelper: AudioSessionHelperType
    ) {
        self.player = player
        self.queuingHelper = .init(queuePlayer: player)
        self.playbackQueue = playbackQueue
        self.audioSessionHelper = audioSessionHelper

        try? audioSessionHelper.configureAudio()

        configurePlaybackQueueBinding(playbackQueue, player: player)
        configureTimingEvents(player: player)
    }

    private func configurePlaybackQueueBinding<P: QueuePlayerType>(_ playbackQueue: some PlaybackQueueType, player: P) {
        let queuingHelper = queuingHelper

        var nextPlayerItem: P.Item?

        // TODO: set up some form of error handling if currentItemStatusPublisher emits .failed
        //  This can happen if the media failed to load, so it may be appropriate to skip to next item or show an error message.
        playbackQueue.state
            .map { ($0.activeItem, $0.nextItem) }
            .sink { currentItemID, nextItemID in
                queuingHelper.setCurrentItem(.init(from: currentItemID))
                queuingHelper.setNextItem(.init(from: nextItemID))

                nextPlayerItem = player.items()[safe: 1]
            }
            .store(in: &disposeBag)

        player.currentItemPublisher
            .unwrapped()
            .sink { currentItem in
                if currentItem == nextPlayerItem {
                    nextPlayerItem = nil
                    playbackQueue.goToNextItem()
                }
            }
            .store(in: &disposeBag)
    }

    private func configureTimingEvents(player: some QueuePlayerType) {
        let currentItemPublisher = player.currentItemPublisher
        let currentItemStatusPublisher = player.currentItemStatusPublisher
        let periodicTimePublisher = player.periodicTimePublisher

        Publishers.Merge4(
            currentItemPublisher.mapToVoid(),
            currentItemStatusPublisher.mapToVoid(),
            periodicTimePublisher.mapToVoid().filter { [weak self] in self?.activeSeekTarget.value == nil },
            activeSeekTarget.mapToVoid()
        )
        .sink { [weak self] in
            guard let self else { return }
            if let currentItem = player.currentItem {
                timing = .init(from: currentItem)
                if let activeSeekTarget = activeSeekTarget.value {
                    timing?.elapsedDuration = activeSeekTarget.seconds
                }
            } else {
                timing = nil
            }
        }
        .store(in: &disposeBag)

        player.isPlaying
            .sink { [weak self] in
                self?.isPlaying = $0
            }
            .store(in: &disposeBag)
    }

    @MainActor
    func play() {
        guard player.currentItem != nil else {
            pause()
            return
        }
        activePlayTaskCancellable?.cancel()
        let playTask = Task { @MainActor in
            do {
                try await audioSessionHelper.activateAudio()
                guard !Task.isCancelled else {
                    return
                }
                player.play()
            } catch {
                pause()
            }
        }
        activePlayTaskCancellable = playTask.anyCancellable
    }

    @MainActor
    func pause() {
        activePlayTaskCancellable?.cancel()
        player.pause()
    }

    func seek(to time: TimeInterval) {
        let targetTime = CMTime(seconds: time, preferredTimescale: 100)
        let seekTolerance = CMTime(value: 1, timescale: 10) // Allow seek error up to 1/10th of a second

        activeSeekTaskCancellable?.cancel()
        let seekTask = Task { @MainActor in
            activeSeekTarget.send(targetTime)
            await player.seek(
                to: targetTime,
                toleranceBefore: seekTolerance,
                toleranceAfter: seekTolerance
            )
            guard !Task.isCancelled else { return }
            activeSeekTarget.send(nil)
        }
        activeSeekTaskCancellable = seekTask.anyCancellable
    }

    func skipBackward() {
        // TODO: impl
    }

    func skipForward() {
        // TODO: impl
    }
}
