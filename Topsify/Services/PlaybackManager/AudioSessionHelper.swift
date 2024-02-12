// Created by Alex Yaro on 2024-02-03.

import AVFoundation
import Combine
import Foundation

protocol AudioSessionHelperType {
    var otherAppsPlayingAudioNotificationPublisher: AnyPublisher<Bool, Never> { get }

    func configureAudio() throws
    func activateAudio() async throws
}

class AudioSessionHelper: AudioSessionHelperType {
    private let audioSession = AVAudioSession.sharedInstance()
    private let notificationCenter = NotificationCenter.default
    private let queue = DispatchQueue(label: String(describing: AudioSessionHelper.self), qos: .userInitiated)

    var otherAppsPlayingAudioNotificationPublisher: AnyPublisher<Bool, Never> {
        notificationCenter.publisher(for: AVAudioSession.silenceSecondaryAudioHintNotification)
            .compactMap {
                if
                    let userInfo = $0.userInfo,
                    let typeValue = userInfo[AVAudioSessionSilenceSecondaryAudioHintTypeKey] as? UInt,
                    let type = AVAudioSession.SilenceSecondaryAudioHintType(rawValue: typeValue)
                {
                    return type == .begin ? true : false
                }
                return nil
            }
            .eraseToAnyPublisher()
    }

    func configureAudio() throws {
        try audioSession.setCategory(.playback, mode: .moviePlayback)
    }
    
    @MainActor
    func activateAudio() async throws {
        let audioSession = audioSession
        try await withCheckedThrowingContinuation { continuation in
            queue.async {
                do {
                    try audioSession.setActive(true)
                    continuation.resume()
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
