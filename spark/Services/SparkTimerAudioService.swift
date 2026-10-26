//
//  SparkTimerAudioService.swift
//  Spark
//
//  Purpose:
//  One-shot alarm playback for the standalone timer.
//
//  Responsibilities:
//  • Plays timer completion sounds independently from music.
//

import AVFoundation
import Foundation

/// One-shot alarm player for the standalone Timer — kept separate from Spark Music.
final class SparkTimerAudioService {
    static let shared = SparkTimerAudioService()

    private var player: AVPlayer?

    private init() {
        configureAudioSession()
    }

    func play(soundID: String) {
        let sound = TimerSounds.sound(for: soundID)
        guard let url = sound.url else { return }

        let item = AVPlayerItem(url: url)
        if player == nil {
            player = AVPlayer(playerItem: item)
        } else {
            player?.replaceCurrentItem(with: item)
        }
        player?.seek(to: .zero)
        player?.play()
    }

    func stop() {
        player?.pause()
    }

    private func configureAudioSession() {
        #if os(iOS)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default)
            try session.setActive(true)
        } catch {
            // Non-fatal — haptics still alert the user.
        }
        #endif
    }
}
