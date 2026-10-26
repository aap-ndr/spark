//
//  FocusTimerEngine.swift
//  Spark
//
//  Purpose:
//  Focus Realms timer engine and session recording rules.
//
//  Responsibilities:
//  • Runs countdown timing with pause, resume, and reset behavior.
//  • Records elapsed focus time without duplicate session entries.
//

import Foundation
import Observation

/// Timer engine for Focus Realms.
///
/// Recording rules:
/// - Credit elapsed focus time when the user pauses, resets early, or completes.
/// - `hasRecorded` prevents duplicate `addSession` calls within one play segment.
/// - Each press of Start clears `hasRecorded` so a resumed session can record again.
/// - Pause/resume preserves remaining time; stats update on pause once elapsed ≥ 1s.
@Observable
final class FocusTimerEngine {
    var selectedRealmID: FocusRealmID = .forest
    var selectedMinutes = 15
    var running = false
    var finished = false
    var musicEnabled = true
    var encouragementIndex = 0
    var notice: String?
    private(set) var pausedByMusicCoupling = false

    private var remainingSeconds = 15 * 60
    private var runStartRemaining = 15 * 60
    private var segmentStart: Date?
    private var logicalSessionActive = false
    private var accumulatedRunningSeconds: TimeInterval = 0
    private var hasRecorded = false
    private var lastEncouragementTick: Date?

    var selectedRealm: FocusRealm {
        FocusContent.realm(for: selectedRealmID)
    }

    func remaining(at now: Date = Date()) -> Int {
        guard running, let start = segmentStart else { return remainingSeconds }
        let segmentElapsed = Int(now.timeIntervalSince(start))
        return max(0, runStartRemaining - segmentElapsed)
    }

    func progress(at now: Date = Date()) -> Double {
        let total = selectedMinutes * 60
        guard total > 0 else { return 0 }
        return Double(total - remaining(at: now)) / Double(total)
    }

    func statusLabel(at now: Date = Date()) -> String {
        if running { return "focusing…" }
        if finished { return "all done 🌟" }
        return "ready when you are"
    }

    func syncDuration(minutes: Int) {
        guard !running else { return }
        selectedMinutes = minutes
        remainingSeconds = minutes * 60
        finished = false
    }

    func start(focusStore: FocusStore, musicStore: MusicStore? = nil) {
        if remainingSeconds == 0 || finished {
            remainingSeconds = selectedMinutes * 60
        }

        finished = false
        notice = nil
        hasRecorded = false
        pausedByMusicCoupling = false

        if !logicalSessionActive {
            logicalSessionActive = true
            accumulatedRunningSeconds = 0
        }

        runStartRemaining = remainingSeconds
        segmentStart = nowDate()
        running = true
        lastEncouragementTick = nowDate()
        focusStore.setActiveRealm(name: selectedRealm.name)

        if musicEnabled {
            musicStore?.playTrack(selectedRealm.trackID)
        }

        SparkHaptics.mediumImpact()
    }

    func pause(focusStore: FocusStore, musicStore: MusicStore? = nil) {
        guard running else { return }

        pausedByMusicCoupling = false
        let now = nowDate()
        remainingSeconds = remaining(at: now)
        if let start = segmentStart {
            accumulatedRunningSeconds += now.timeIntervalSince(start)
        }
        segmentStart = nil
        running = false

        recordElapsed(seconds: Int(accumulatedRunningSeconds), focusStore: focusStore)

        focusStore.setActiveRealm(name: nil)

        pauseRealmMusic(musicStore: musicStore)
        SparkHaptics.lightImpact()
    }

    /// Pauses the timer when realm music stops, without recording stats or touching playback.
    func pauseForMusicCoupling(focusStore: FocusStore, allowMusicResume: Bool = true) {
        guard running else { return }

        let now = nowDate()
        remainingSeconds = remaining(at: now)
        if let start = segmentStart {
            accumulatedRunningSeconds += now.timeIntervalSince(start)
        }
        segmentStart = nil
        running = false
        pausedByMusicCoupling = allowMusicResume
            && logicalSessionActive
            && !finished
            && remainingSeconds > 0
        focusStore.setActiveRealm(name: nil)
    }

    /// Resumes the timer when the user starts the same realm track again.
    func resumeFromMusicCoupling(focusStore: FocusStore) {
        guard pausedByMusicCoupling, !finished, remainingSeconds > 0 else { return }

        pausedByMusicCoupling = false
        notice = nil
        runStartRemaining = remainingSeconds
        segmentStart = nowDate()
        running = true
        lastEncouragementTick = nowDate()
        focusStore.setActiveRealm(name: selectedRealm.name)
        SparkHaptics.lightImpact()
    }

    func reset(focusStore: FocusStore, musicStore: MusicStore? = nil) {
        let now = nowDate()
        if running {
            commitRunningSegment(at: now)
            recordElapsed(seconds: Int(accumulatedRunningSeconds), focusStore: focusStore)
        }

        stopRealmMusic(musicStore: musicStore)
        running = false
        finished = false
        pausedByMusicCoupling = false
        remainingSeconds = selectedMinutes * 60
        logicalSessionActive = false
        accumulatedRunningSeconds = 0
        hasRecorded = false
        segmentStart = nil
        notice = nil
        focusStore.setActiveRealm(name: nil)
        SparkHaptics.lightImpact()
    }

    func tick(focusStore: FocusStore, musicStore: MusicStore? = nil, at now: Date = Date()) {
        guard running else { return }

        if remaining(at: now) <= 0 {
            completeNaturally(focusStore: focusStore, musicStore: musicStore)
            return
        }

        if let lastEncouragementTick,
           now.timeIntervalSince(lastEncouragementTick) >= 4 {
            encouragementIndex = (encouragementIndex + 1) % FocusContent.encouragements.count
            self.lastEncouragementTick = now
        }
    }

    func toggleMusic(musicStore: MusicStore? = nil) {
        musicEnabled.toggle()
        if musicEnabled && running {
            musicStore?.playTrack(selectedRealm.trackID)
        } else if musicStore?.currentTrackId == selectedRealm.trackID {
            musicStore?.pause()
        }
        SparkHaptics.lightImpact()
    }

    func selectRealm(_ id: FocusRealmID, musicStore: MusicStore? = nil) {
        guard !running else { return }
        selectedRealmID = id
        if !(musicStore?.isPlaying ?? false) {
            SparkMusicAudioService.shared.preload(
                trackID: selectedRealm.trackID,
                isPlaying: musicStore?.isPlaying ?? false
            )
        }
        SparkHaptics.lightImpact()
    }

    func completeNaturally(focusStore: FocusStore, musicStore: MusicStore?) {
        guard !hasRecorded else { return }

        commitRunningSegment(at: nowDate())
        running = false
        finished = true
        remainingSeconds = 0
        segmentStart = nil
        stopRealmMusic(musicStore: musicStore)
        recordElapsed(seconds: selectedMinutes * 60, focusStore: focusStore)
        logicalSessionActive = false
        accumulatedRunningSeconds = 0
        pausedByMusicCoupling = false
        focusStore.setActiveRealm(name: nil)
        SparkHaptics.successNotification()
    }

    func flashNotice(_ message: String) {
        notice = message
    }

    func clearNotice() {
        notice = nil
    }

    func pauseRealmMusic(musicStore: MusicStore?) {
        guard musicStore?.currentTrackId == selectedRealm.trackID else { return }
        musicStore?.pause()
    }

    func stopRealmMusic(musicStore: MusicStore?) {
        guard musicStore?.currentTrackId == selectedRealm.trackID else { return }
        musicStore?.stop()
    }

    private func nowDate() -> Date { Date() }

    private func commitRunningSegment(at now: Date) {
        guard running, let start = segmentStart else { return }
        accumulatedRunningSeconds += now.timeIntervalSince(start)
        segmentStart = nil
    }

    private func recordElapsed(seconds: Int, focusStore: FocusStore) {
        guard !hasRecorded else { return }
        guard seconds >= 1 else { return }
        hasRecorded = true
        let minutes = seconds / 60
        focusStore.addSession(
            minutes: minutes,
            realmID: selectedRealm.id.rawValue,
            realmName: selectedRealm.name
        )
    }
}
