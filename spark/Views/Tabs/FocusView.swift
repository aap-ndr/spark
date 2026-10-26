//
//  FocusView.swift
//  Spark
//
//  Purpose:
//  Focus tab screen for Focus Realms.
//
//  Responsibilities:
//  • Hosts realm selection, timer controls, and music coupling.
//  • Surfaces focus stats and realm scene presentation.
//

import SwiftUI

private enum FocusDestination: Hashable {
    case tracker
}

struct FocusView: View {
    @Environment(FocusStore.self) private var focusStore
    @Environment(MusicStore.self) private var musicStore
    @State private var engine = FocusTimerEngine()
    @State private var navigationPath = NavigationPath()
    @State private var focusStoppingMusic = false
    @State private var musicConfirmed = false
    @State private var noticeDismissTask: Task<Void, Never>?

    var body: some View {
        NavigationStack(path: $navigationPath) {
            focusContent
                .navigationDestination(for: FocusDestination.self) { destination in
                    switch destination {
                    case .tracker:
                        FocusTrackerView()
                    }
                }
        }
    }

    private var focusContent: some View {
        ZStack(alignment: .top) {
            SparkColors.cream.ignoresSafeArea()

            LinearGradient(
                colors: [engine.selectedRealm.backdrop.first ?? SparkColors.mint, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)

            TimelineView(.periodic(from: .now, by: 1.0)) { context in
                let now = context.date
                let _ = engine.tick(focusStore: focusStore, musicStore: musicStore, at: now)
                let remaining = engine.remaining(at: now)
                let progress = engine.progress(at: now)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        headerSection
                        realmPickerSection
                        durationSection
                        sceneSection(remaining: remaining, progress: progress, at: now)
                        controlsSection
                        completionSection
                    }
                    .padding(.horizontal, SparkSpacing.screenHorizontal)
                    .padding(.bottom, 60)
                }
                .safeAreaPadding(.top, SparkSpacing.md)
                .scrollIndicators(.hidden)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            preloadSelectedRealmTrack()
        }
        .onChange(of: engine.selectedRealmID) { _, _ in
            preloadSelectedRealmTrack()
        }
        .onChange(of: engine.running) { _, running in
            syncRealmMusicWithTimer(running: running)
        }
        .onChange(of: engine.musicEnabled) { _, _ in
            syncRealmMusicWithTimer(running: engine.running)
        }
        .onChange(of: musicStore.isPlaying) { _, isPlaying in
            handleExternalMusicChange(isPlaying: isPlaying)
        }
        .onChange(of: musicStore.currentTrackId) { _, trackID in
            handleExternalTrackChange(trackID: trackID)
        }
        .onChange(of: engine.finished) { _, finished in
            if finished {
                focusStoppingMusic = true
            }
        }
        .onDisappear {
            noticeDismissTask?.cancel()
            if engine.running {
                focusStore.setActiveRealm(name: nil)
            }
        }
    }

    private func preloadSelectedRealmTrack() {
        guard !engine.running, !musicStore.isPlaying else { return }
        SparkMusicAudioService.shared.preload(
            trackID: engine.selectedRealm.trackID,
            isPlaying: musicStore.isPlaying
        )
    }

    private func syncRealmMusicWithTimer(running: Bool) {
        if running && engine.musicEnabled {
            musicConfirmed = false
            musicStore.playTrack(engine.selectedRealm.trackID)
        } else if musicStore.currentTrackId == engine.selectedRealm.trackID {
            focusStoppingMusic = true
            engine.pauseRealmMusic(musicStore: musicStore)
        }
    }

    private func handleExternalMusicChange(isPlaying: Bool) {
        guard engine.musicEnabled else { return }

        let isRealmTrack = musicStore.currentTrackId == engine.selectedRealm.trackID

        if isPlaying, isRealmTrack {
            musicConfirmed = true
            if focusStoppingMusic {
                focusStoppingMusic = false
                return
            }
            if engine.pausedByMusicCoupling {
                engine.resumeFromMusicCoupling(focusStore: focusStore)
            }
            return
        }

        if focusStoppingMusic {
            focusStoppingMusic = false
            return
        }

        guard engine.running, musicConfirmed else { return }

        engine.pauseForMusicCoupling(focusStore: focusStore)
        if !isPlaying {
            showFocusNotice("Focus paused — your music stopped 💗")
        } else {
            showFocusNotice("Focus paused — your music changed 💗")
        }
    }

    private func handleExternalTrackChange(trackID: String?) {
        guard engine.running, engine.musicEnabled, musicConfirmed else { return }
        if focusStoppingMusic { return }
        guard trackID != engine.selectedRealm.trackID else { return }

        engine.pauseForMusicCoupling(focusStore: focusStore, allowMusicResume: false)
        showFocusNotice("Focus paused — your music changed 💗")
    }

    private func showFocusNotice(_ message: String) {
        engine.flashNotice(message)
        noticeDismissTask?.cancel()
        noticeDismissTask = Task {
            try? await Task.sleep(for: .seconds(5))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                engine.clearNotice()
            }
        }
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Focus Realms")
                    .sparkTitle()
                Text("You've focused \(focusStore.totalMinutes) min · \(focusStore.sessionsCompleted) sessions · \(focusStore.sparksEarned) ✨")
                    .font(SparkTypography.body())
                    .foregroundStyle(SparkColors.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                SparkHaptics.lightImpact()
                navigationPath.append(FocusDestination.tracker)
            } label: {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(SparkColors.lavender)
                    .frame(width: 44, height: 44)
                    .background(SparkColors.card)
                    .clipShape(Capsule())
                    .sparkSoftShadow()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open focus tracker")
        }
        .sparkFadeInDown(duration: 0.4)
    }

    private var realmPickerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("CHOOSE YOUR REALM")
                .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 22)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: SparkSpacing.sm) {
                    ForEach(FocusContent.realms) { realm in
                        let active = realm.id == engine.selectedRealmID
                        Button {
                            engine.selectRealm(realm.id, musicStore: musicStore)
                        } label: {
                            VStack(alignment: .leading, spacing: 0) {
                                Text(realm.emoji)
                                    .font(.system(size: 30))
                                Spacer(minLength: 0)
                                Text(realm.name)
                                    .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                                    .foregroundStyle(SparkColors.white)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(14)
                            .frame(width: 110, height: 120, alignment: .leading)
                            .background(SparkTheme.gradient(realm.gradient))
                            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous)
                                    .stroke(SparkColors.white, lineWidth: active ? 3 : 0)
                            )
                            .sparkSoftShadow()
                            .opacity(engine.running && !active ? 0.5 : 1)
                        }
                        .buttonStyle(.plain)
                        .disabled(engine.running)
                        .accessibilityLabel(realm.name)
                        .accessibilityAddTraits(active ? .isSelected : [])
                    }
                }
                .padding(.top, SparkSpacing.sm)
            }
        }
        .sparkFadeInDown(delay: 0.1)
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("HOW LONG?")
                .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 22)

            HStack(spacing: 10) {
                ForEach(FocusContent.durations, id: \.self) { duration in
                    let active = duration == engine.selectedMinutes
                    Button {
                        engine.syncDuration(minutes: duration)
                        SparkHaptics.lightImpact()
                    } label: {
                        VStack(spacing: 0) {
                            Text("\(duration)")
                                .font(SparkTypography.font(.displayBold, size: 17, relativeTo: .body))
                                .foregroundStyle(active ? SparkColors.white : SparkColors.ink)
                            Text("min")
                                .font(SparkTypography.font(.body, size: 11, relativeTo: .caption2))
                                .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(active ? SparkColors.lavender : SparkColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        .sparkSoftShadow()
                        .opacity(engine.running ? 0.6 : 1)
                    }
                    .buttonStyle(.plain)
                    .disabled(engine.running)
                    .accessibilityLabel("\(duration) minutes")
                    .accessibilityAddTraits(active ? .isSelected : [])
                }
            }
            .padding(.top, SparkSpacing.sm)
        }
        .sparkFadeInDown(delay: 0.16)
    }

    private func sceneSection(remaining: Int, progress: Double, at now: Date) -> some View {
        VStack(spacing: 0) {
            RealmSceneView(realm: engine.selectedRealm, height: FocusContent.sceneHeight) {
                FocusTimerRingView(
                    realm: engine.selectedRealm,
                    remaining: remaining,
                    progress: progress,
                    statusLabel: engine.statusLabel(at: now)
                )
            }
            .sparkSoftShadow()

            Text(engine.running
                ? FocusContent.encouragements[engine.encouragementIndex]
                : engine.selectedRealm.ambient)
                .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                .foregroundStyle(SparkColors.inkSoft)
                .multilineTextAlignment(.center)
                .frame(minHeight: 24)
                .padding(.horizontal, 10)
                .padding(.top, 16)

            if let notice = engine.notice {
                Text(notice)
                    .font(SparkTypography.accentLink())
                    .foregroundStyle(SparkColors.lavender)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 10)
                    .padding(.horizontal, SparkSpacing.md)
                    .background(SparkColors.lavenderSoft)
                    .clipShape(Capsule())
                    .padding(.top, SparkSpacing.sm)
            }

            VStack(spacing: SparkSpacing.xs) {
                Button {
                    engine.toggleMusic(musicStore: musicStore)
                } label: {
                    HStack(spacing: SparkSpacing.xs) {
                        Image(systemName: engine.musicEnabled ? "music.note" : "speaker.slash")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(engine.musicEnabled ? SparkColors.white : SparkColors.inkSoft)
                        Text(engine.musicEnabled ? "Music on" : "Music off")
                            .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                            .foregroundStyle(engine.musicEnabled ? SparkColors.white : SparkColors.inkSoft)
                    }
                    .padding(.vertical, 11)
                    .padding(.horizontal, 18)
                    .background(engine.musicEnabled ? SparkColors.lavender : SparkColors.card)
                    .clipShape(Capsule())
                    .sparkSoftShadow()
                }
                .buttonStyle(.plain)
                .frame(minHeight: 44)
                .accessibilityLabel(engine.musicEnabled ? "Music on" : "Music off")

                Text(engine.musicEnabled
                    ? "Calm music plays while your timer runs 🎧"
                    : "Your session will be silent 🤫")
                    .font(SparkTypography.caption())
                    .foregroundStyle(SparkColors.inkSoft)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 14)
        }
        .padding(.top, 26)
        .sparkFadeInDown(delay: 0.22)
    }

    private var controlsSection: some View {
        HStack(spacing: 18) {
            Button {
                focusStoppingMusic = true
                engine.reset(focusStore: focusStore, musicStore: musicStore)
            } label: {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(SparkColors.inkSoft)
                    .frame(width: 60, height: 60)
                    .background(SparkColors.card)
                    .clipShape(Circle())
                    .sparkSoftShadow()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reset focus session")

            Button {
                if engine.running {
                    engine.pause(focusStore: focusStore, musicStore: musicStore)
                } else {
                    engine.start(focusStore: focusStore, musicStore: musicStore)
                }
            } label: {
                Image(systemName: engine.running ? "pause.fill" : "play.fill")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(SparkColors.white)
                    .offset(x: engine.running ? 0 : 2)
                    .frame(width: 88, height: 88)
                    .background(SparkTheme.gradient(engine.selectedRealm.gradient))
                    .clipShape(Circle())
                    .sparkSoftShadow()
            }
            .buttonStyle(.plain)
            .accessibilityLabel(engine.running ? "Pause focus session" : "Start focus session")

            Image(systemName: "stopwatch")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(SparkColors.inkSoft)
                .frame(width: 60, height: 60)
                .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 22)
        .sparkFadeInDown(delay: 0.3)
    }

    @ViewBuilder
    private var completionSection: some View {
        if engine.finished {
            VStack(spacing: 0) {
                Text("🌟")
                    .font(.system(size: 40))
                Text("You focused for \(engine.selectedMinutes) minutes!")
                    .font(SparkTypography.font(.displayBold, size: 19, relativeTo: .title3))
                    .foregroundStyle(SparkColors.ink)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
                Text("Take a mindful break now — stretch, sip some water, or look out a window. You earned it. 💗")
                    .font(SparkTypography.font(.body, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(SparkColors.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(7)
                    .padding(.top, 6)
            }
            .padding(SparkSpacing.cardPadding)
            .frame(maxWidth: .infinity)
            .background(SparkColors.mintSoft)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
            .sparkSoftShadow()
            .padding(.top, 26)
            .sparkFadeInDown(delay: 0.35)
        }
    }
}

#Preview {
    FocusView()
        .environment(FocusStore())
        .environment(MusicStore())
        .preferredColorScheme(.light)
}
