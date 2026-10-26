//
//  MusicPlaybackBridge.swift
//  Spark
//
//  Purpose:
//  Bridge between MusicStore intent and the audio engine.
//
//  Responsibilities:
//  • Synchronizes playback commands with SparkMusicAudioService.
//

import SwiftUI

/// Keeps the global audio engine in sync with `MusicStore` intent.
struct MusicPlaybackBridge: View {
    @Environment(MusicStore.self) private var musicStore

    var body: some View {
        Color.clear
            .frame(width: 0, height: 0)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
            .onAppear {
                SparkMusicAudioService.shared.onTrackFinished = { [musicStore] in
                    musicStore.next()
                }
                SparkMusicAudioService.shared.sync(
                    currentTrackID: musicStore.currentTrackId,
                    isPlaying: musicStore.isPlaying
                )
            }
            .onChange(of: musicStore.currentTrackId) { _, trackID in
                SparkMusicAudioService.shared.sync(
                    currentTrackID: trackID,
                    isPlaying: musicStore.isPlaying
                )
            }
            .onChange(of: musicStore.isPlaying) { _, isPlaying in
                SparkMusicAudioService.shared.sync(
                    currentTrackID: musicStore.currentTrackId,
                    isPlaying: isPlaying
                )
            }
    }
}
