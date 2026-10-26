//
//  MiniPlayerBar.swift
//  Spark
//
//  Purpose:
//  Persistent mini player bar for music playback.
//
//  Responsibilities:
//  • Shows current track controls above the tab bar.
//

import SwiftUI

struct MiniPlayerBar: View {
    @Environment(MusicStore.self) private var musicStore
    @Environment(AppNavigationCoordinator.self) private var navigation

    private var track: MusicTrack? {
        MusicLibrary.track(id: musicStore.currentTrackId)
    }

    var body: some View {
        if let track {
            VStack(spacing: 0) {
                Spacer(minLength: 0)

                Button {
                    openMusic()
                } label: {
                    HStack(spacing: 10) {
                        TrackArtworkView(urlString: track.artworkURL, size: 42, cornerRadius: SparkRadius.pill)

                        VStack(alignment: .leading, spacing: 0) {
                            Text(track.title)
                                .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                                .foregroundStyle(SparkColors.white)
                                .lineLimit(1)

                            Text(track.mood)
                                .font(SparkTypography.font(.body, size: 11, relativeTo: .caption2))
                                .foregroundStyle(Color.white.opacity(0.85))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Button {
                            SparkHaptics.lightImpact()
                            musicStore.togglePlayPause()
                        } label: {
                            Image(systemName: musicStore.isPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(SparkColors.white)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel(musicStore.isPlaying ? "Pause" : "Play")

                        Button {
                            SparkHaptics.lightImpact()
                            musicStore.next()
                        } label: {
                            Image(systemName: "forward.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(SparkColors.white)
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Next track")

                        Button {
                            SparkHaptics.mediumImpact()
                            musicStore.stop()
                            SparkMusicAudioService.shared.stop()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(Color.white.opacity(0.9))
                                .frame(width: 44, height: 44)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Stop playback")
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    .background(
                        LinearGradient(
                            colors: [SparkColors.lavender, Color(sparkHex: 0x5B15C9)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Capsule())
                    .sparkSoftShadow()
                }
                .buttonStyle(.plain)
                .padding(.horizontal, SparkSpacing.sm)
                .padding(.bottom, 68)
                .accessibilityLabel("Now playing \(track.title). Open music.")
            }
            .allowsHitTesting(true)
        }
    }

    private func openMusic() {
        SparkHaptics.lightImpact()
        navigation.selectedTab = .home
        navigation.homePath.append(AppRoute.music)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        SparkColors.cream.ignoresSafeArea()
        MiniPlayerBar()
    }
    .environment(MusicStore())
    .environment(AppNavigationCoordinator())
}
