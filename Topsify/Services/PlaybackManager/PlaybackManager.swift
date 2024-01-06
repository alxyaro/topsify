// Created by Alex Yaro on 2023-12-31.

import AVFoundation
import Combine
import Foundation

final class PlaybackManager: PlaybackManagerType {

    var statusPublisher: AnyPublisher<PlaybackStatus, Never> {
        $status.eraseToAnyPublisher()
    }

    var timingPublisher: AnyPublisher<PlaybackTiming?, Never> {
        $timing.eraseToAnyPublisher()
    }

    @SubjectBacked var status = PlaybackStatus.notPlaying
    @SubjectBacked var timing: PlaybackTiming?

    private let player = AVPlayer()
    private let playbackQueue: any PlaybackQueueType
    private var audioSession: AVAudioSession
    private var disposeBag = DisposeBag()
    private var activeSeekTarget = CurrentValueSubject<CMTime?, Never>(nil)

    init(playbackQueue: any PlaybackQueueType, audioSession: AVAudioSession) {
        self.playbackQueue = playbackQueue
        self.audioSession = audioSession

        try? audioSession.setCategory(.playback, mode: .moviePlayback)

        configurePlayerItemPopulation(playbackQueue)
        configureTimingEvents()
    }

    private func configurePlayerItemPopulation(_ playbackQueue: some PlaybackQueueType) {
        playbackQueue.state
            .map(\.activeItem?.song.streamURL)
            .reEmit(onOutputFrom: player.publisher(for: \.status)
                .removeDuplicates()
                .filter { $0 == .failed }
            )
            .sink { [weak self] streamURL in
                guard let self else { return }
                if let streamURL {
                    let playerItem = AVPlayerItem(url: streamURL)
                    player.replaceCurrentItem(with: playerItem)
                    player.seek(to: .zero)
                } else {
                    player.replaceCurrentItem(with: nil)
                }
            }
            .store(in: &disposeBag)
    }

    private func configureTimingEvents() {
        let currentItemPublisher = player.publisher(for: \.currentItem)

        let currentItemStatusPublisher = player.publisher(for: \.currentItem)
            .map { currentItem -> AnyPublisher<AVPlayerItem.Status, Never> in
                if let currentItem {
                    currentItem.publisher(for: \.status, options: [.initial, .new]).eraseToAnyPublisher()
                } else {
                    AnyPublisher.never()
                }
            }
            .switchToLatest()

        let periodicTimePublisher = player.periodicTimePublisher(forInterval: CMTime(value: 1, timescale: 5))

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
    }

    func play() {
        guard player.currentItem != nil else {
            pause()
            return
        }
        do {
            try audioSession.setActive(true)
            status = .playing
            player.play()
        } catch {
            pause()
        }
    }
    
    func pause() {
        status = .notPlaying
        player.pause()
    }
    
    func seek(to time: TimeInterval) {
        let targetTime = CMTime(seconds: time, preferredTimescale: 100)
        let seekTolerance = CMTime(value: 1, timescale: 10) // Allow seek error up to 1/10th of a second

        activeSeekTarget.send(targetTime)
        player.seek(
            to: targetTime,
            toleranceBefore: seekTolerance,
            toleranceAfter: seekTolerance,
            completionHandler: { [weak self] _ in
                guard let self else { return }
                if activeSeekTarget.value == targetTime {
                    activeSeekTarget.send(nil)
                }
            }
        )
    }

    func skipBackward() {
        // TODO: impl
    }

    func skipForward() {
        // TODO: impl
    }
}
