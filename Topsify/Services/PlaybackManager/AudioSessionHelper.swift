// Created by Alex Yaro on 2024-02-03.

import AVFoundation
import Foundation

protocol AudioSessionHelperType {
    func configureAudio() throws
    func activateAudio() async throws
}

class AudioSessionHelper: AudioSessionHelperType {
    private let audioSession = AVAudioSession.sharedInstance()
    private let queue = DispatchQueue(label: String(describing: AudioSessionHelper.self), qos: .userInitiated)

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
