//
//  SparkMusicAudioService.swift
//  Spark
//
//  Purpose:
//  Shared audio engine for music and focus realm tracks.
//
//  Responsibilities:
//  • Streams library tracks and reports playback status.
//

import AVFoundation
import Foundation
import Observation

enum SparkMusicPlaybackStatus: Equatable {
    case idle
    case loading
    case playing
    case paused
    case failed
}

/// Single app-wide audio engine for Spark Music and Focus realm tracks.
/// Streams the same CC-BY / royalty-free URLs defined in `MusicLibrary`.
@Observable
final class SparkMusicAudioService {
    static let shared = SparkMusicAudioService()

    private(set) var status: SparkMusicPlaybackStatus = .idle
    private(set) var loadedTrackID: String?
    /// True when streaming track URLs are configured in `MusicLibrary`.
    let isStreamingConfigured = true

    var onTrackFinished: (() -> Void)?

    private var player: AVPlayer?
    private var endObserver: NSObjectProtocol?

    private init() {
        configureAudioSession()
    }

    func sync(currentTrackID: String?, isPlaying: Bool) {
        guard let currentTrackID else {
            player?.pause()
            loadedTrackID = nil
            status = .idle
            return
        }

        if currentTrackID != loadedTrackID {
            loadTrack(id: currentTrackID, autoplay: isPlaying)
            return
        }

        if isPlaying {
            player?.play()
            status = .playing
        } else {
            player?.pause()
            status = .paused
        }
    }

    func preload(trackID: String, isPlaying: Bool) {
        guard !isPlaying else { return }
        guard trackID != loadedTrackID else { return }
        loadTrack(id: trackID, autoplay: false)
    }

    func stop() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        loadedTrackID = nil
        status = .idle
    }

    private func configureAudioSession() {
        #if os(iOS)
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
        } catch {
            status = .failed
        }
        #endif
    }

    private func loadTrack(id: String, autoplay: Bool) {
        guard let track = MusicLibrary.track(id: id),
              let url = URL(string: track.streamURL) else {
            status = .failed
            return
        }

        removeEndObserver()
        status = .loading

        let item = AVPlayerItem(url: url)
        if player == nil {
            player = AVPlayer(playerItem: item)
        } else {
            player?.replaceCurrentItem(with: item)
        }

        loadedTrackID = id

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: item,
            queue: .main
        ) { [weak self] _ in
            self?.onTrackFinished?()
        }

        if autoplay {
            player?.seek(to: .zero)
            player?.play()
            status = .playing
        } else {
            player?.pause()
            player?.seek(to: .zero)
            status = .paused
        }
    }

    private func removeEndObserver() {
        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
            self.endObserver = nil
        }
    }

    deinit {
        removeEndObserver()
    }
}
