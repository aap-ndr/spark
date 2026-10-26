//
//  MusicView.swift
//  Spark
//
//  Purpose:
//  Spark Music browsing and playback screen.
//
//  Responsibilities:
//  • Lists tracks, controls playback, and integrates the mini player.
//

import SwiftUI

struct MusicView: View {
    @Environment(MusicStore.self) private var musicStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var filter: MusicFilter = .all

    private var visibleTracks: [MusicTrack] {
        MusicContent.tracks(for: filter, favorites: musicStore.favorites)
    }

    var body: some View {
        ZStack(alignment: .top) {
            SparkColors.cream.ignoresSafeArea()

            LinearGradient(
                colors: [SparkColors.lavender, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 240)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    filterChipsSection
                    trackListSection
                    creditSection
                }
                .padding(.bottom, 160)
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .safeAreaPadding(.top, SparkSpacing.md)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: SparkSpacing.xs) {
                Image(systemName: "music.note")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(SparkColors.white)
                Text("Your Sounds")
                    .font(SparkTypography.title())
                    .foregroundStyle(SparkColors.white)
            }

            Text("Focus, relax, breathe — or just vibe 🎧")
                .font(SparkTypography.body())
                .foregroundStyle(Color.white.opacity(0.92))
        }
        .padding(.horizontal, SparkSpacing.screenHorizontal)
        .sparkFadeInDown(duration: 0.4)
    }

    private var filterChipsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 9) {
                ForEach(MusicContent.filters, id: \.self) { chip in
                    filterChip(chip)
                }
            }
            .padding(.horizontal, SparkSpacing.screenHorizontal)
        }
        .padding(.top, SparkSpacing.lg)
        .sparkFadeInDown(delay: 0.06)
    }

    private func filterChip(_ chip: MusicFilter) -> some View {
        let active = chip == filter

        return Button {
            SparkHaptics.lightImpact()
            filter = chip
        } label: {
            Text(chip.label)
                .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
                .padding(.vertical, 9)
                .padding(.horizontal, SparkSpacing.md)
                .background(active ? SparkColors.lavender : SparkColors.card)
                .clipShape(Capsule())
                .overlay {
                    if !active {
                        Capsule()
                            .stroke(SparkColors.lavenderSoft, lineWidth: 1)
                    }
                }
                .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(chip.label)
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    @ViewBuilder
    private var trackListSection: some View {
        if visibleTracks.isEmpty {
            VStack(spacing: 10) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(SparkColors.lavender)

                Text("No favorites yet — tap the heart on a track to save it here 💗")
                    .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                    .foregroundStyle(SparkColors.inkSoft)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
            .padding(.horizontal, SparkSpacing.screenHorizontal)
            .padding(.top, SparkSpacing.xl)
        } else {
            VStack(spacing: SparkSpacing.sm) {
                ForEach(Array(visibleTracks.enumerated()), id: \.element.id) { index, track in
                    trackRow(track, index: index)
                }
            }
            .padding(.horizontal, SparkSpacing.screenHorizontal)
            .padding(.top, SparkSpacing.xl)
        }
    }

    private func trackRow(_ track: MusicTrack, index: Int) -> some View {
        let active = track.id == musicStore.currentTrackId
        let playingThis = active && musicStore.isPlaying
        let faved = musicStore.isFavorite(track.id)

        return HStack(spacing: 14) {
            TrackArtworkView(urlString: track.artworkURL)

            VStack(alignment: .leading, spacing: 2) {
                Text(track.title)
                    .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                    .foregroundStyle(SparkColors.ink)
                    .lineLimit(1)

                Text(playingThis ? "Now playing…" : track.mood)
                    .font(SparkTypography.supportive())
                    .foregroundStyle(SparkColors.inkSoft)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                SparkHaptics.lightImpact()
                musicStore.toggleFavorite(track.id)
            } label: {
                Image(systemName: faved ? "heart.fill" : "heart")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(faved ? SparkColors.pink : SparkColors.inkSoft)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(faved ? "Remove favorite" : "Add favorite")

            ZStack {
                Circle()
                    .fill(active ? SparkColors.lavender : SparkColors.lavenderSoft)
                    .frame(width: 44, height: 44)

                Image(systemName: playingThis ? "pause.fill" : "play.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(active ? SparkColors.white : SparkColors.lavender)
                    .offset(x: playingThis ? 0 : 2)
            }
        }
        .padding(SparkSpacing.sm)
        .background(SparkColors.card)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous)
                .stroke(active ? SparkColors.lavender : Color.clear, lineWidth: 2)
        }
        .sparkSoftShadow()
        .contentShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
        .onTapGesture {
            SparkHaptics.lightImpact()
            if track.id == musicStore.currentTrackId {
                musicStore.togglePlayPause()
            } else {
                musicStore.playTrack(track.id)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(track.title). \(playingThis ? "Now playing" : track.mood)")
        .accessibilityAddTraits(.isButton)
        .modifier(ConditionalFadeIn(index: index, reduceMotion: reduceMotion))
    }

    private var creditSection: some View {
        Text(MusicLibrary.credit)
            .font(SparkTypography.font(.body, size: 11, relativeTo: .caption2))
            .foregroundStyle(SparkColors.inkSoft)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, SparkSpacing.screenHorizontal)
            .padding(.top, SparkSpacing.xxl)
    }
}

private struct ConditionalFadeIn: ViewModifier {
    let index: Int
    let reduceMotion: Bool
    @State private var visible = false

    func body(content: Content) -> some View {
        content
            .opacity(reduceMotion || visible ? 1 : 0)
            .offset(y: reduceMotion || visible ? 0 : 12)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.easeOut(duration: 0.42).delay(0.06 + Double(min(index, 8)) * 0.045)) {
                    visible = true
                }
            }
    }
}

#Preview {
    NavigationStack {
        MusicView()
            .environment(MusicStore())
    }
}
