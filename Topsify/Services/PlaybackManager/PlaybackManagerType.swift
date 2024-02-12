// Created by Alex Yaro on 2023-12-31.

import Combine
import Foundation

protocol PlaybackManagerType {
    var isPlaying: Bool { get }
    var isPlayingPublisher: AnyPublisher<Bool, Never> { get }
    var timing: PlaybackTiming? { get }
    var timingPublisher: AnyPublisher<PlaybackTiming?, Never> { get }

    func play()
    func pause()
    func seek(to time: TimeInterval)
    func skipBackward()
    func skipForward()
}
