//
//  TimerView.swift
//  Spark
//
//  Purpose:
//  Standalone toolkit timer screen.
//
//  Responsibilities:
//  • Runs preset and custom countdown timers with sounds.
//  • Schedules completion notifications and alarm playback.
//

import SwiftUI

struct TimerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(TimerStore.self) private var timerStore

    @State private var selectedMin: Int = 25
    @State private var remaining = 25 * 60
    @State private var finished = false
    @State private var didTriggerFinish = false
    @State private var scheduledNotificationID: String?
    @State private var buzzTask: Task<Void, Never>?
    @State private var tickTimer: Timer?

    private let presetColumns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
    ]

    private var total: Int {
        if timerStore.running || timerStore.endsAt != nil {
            return timerStore.durationSec
        }
        return selectedMin * 60
    }

    private var shown: Int {
        if timerStore.running {
            return remaining
        }
        if finished {
            return 0
        }
        return total
    }

    private var progress: Double {
        guard total > 0 else { return 0 }
        return min(1, Double(total - shown) / Double(total))
    }

    private var statusLabel: String {
        if timerStore.running {
            return "working…"
        }
        if finished {
            return "all done 🎉"
        }
        return "ready when you are"
    }

    private var canResume: Bool {
        remaining > 0 && remaining < timerStore.durationSec && !finished
    }

    var body: some View {
        ZStack(alignment: .top) {
            SparkColors.cream.ignoresSafeArea()

            LinearGradient(
                colors: [SparkGradientPreset.coral.colors[0], SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    ringSection
                    controlsSection
                    presetsSection
                    soundSection
                    if finished {
                        completionSection
                    }
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.bottom, 60)
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .safeAreaPadding(.top, SparkSpacing.xs)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            selectedMin = max(TimerSounds.minMinutes, timerStore.lastDurationSec / 60)
            remaining = timerStore.remainingSeconds()
            startTickingIfNeeded()
        }
        .onDisappear {
            stopTicking()
            buzzTask?.cancel()
            buzzTask = nil
        }
        .onChange(of: timerStore.running) { _, _ in
            startTickingIfNeeded()
        }
        .onChange(of: timerStore.endsAt) { _, _ in
            startTickingIfNeeded()
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                tick()
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                SparkHaptics.lightImpact()
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(SparkColors.ink)
                    .frame(width: 44, height: 44)
                    .background(SparkColors.card)
                    .clipShape(Circle())
                    .sparkSoftShadow()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Back to Home")

            Text("Timer")
                .sparkTitle()
                .padding(.top, SparkSpacing.md)

            Text("Beat time blindness — start it when you begin, and it'll alarm when you're done. ⏰")
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.inkSoft)
                .lineSpacing(6)
                .padding(.top, 2)
        }
        .sparkFadeInDown(duration: 0.4)
    }

    // MARK: - Ring

    private var ringSection: some View {
        TimerRingView(
            shownSeconds: shown,
            progress: progress,
            statusLabel: statusLabel
        )
        .frame(maxWidth: .infinity)
        .padding(.top, SparkSpacing.section)
        .sparkFadeInDown(delay: 0.12)
    }

    // MARK: - Controls

    private var controlsSection: some View {
        HStack(spacing: 18) {
            Button(action: handleReset) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(SparkColors.inkSoft)
                    .frame(width: 58, height: 58)
                    .background(SparkColors.card)
                    .clipShape(Circle())
                    .sparkSoftShadow()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Reset timer")

            if timerStore.running {
                Button(action: handlePause) {
                    playPauseLabel(systemName: "pause.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Pause timer")
            } else {
                Button(action: canResume ? handleResume : handleStart) {
                    playPauseLabel(systemName: "play.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel(canResume ? "Resume timer" : "Start timer")
            }

            Color.clear
                .frame(width: 58, height: 58)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, SparkSpacing.md)
        .sparkFadeInDown(delay: 0.18)
    }

    private func playPauseLabel(systemName: String) -> some View {
        Image(systemName: systemName)
            .font(.system(size: 36, weight: .semibold))
            .foregroundStyle(SparkColors.white)
            .frame(width: 88, height: 88)
            .background(SparkTheme.gradient(.coral))
            .clipShape(Circle())
            .sparkSoftShadow()
            .offset(x: systemName == "play.fill" ? 2 : 0)
    }

    // MARK: - Presets

    private var presetsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("HOW LONG?")
                .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 26)

            LazyVGrid(columns: presetColumns, spacing: 10) {
                ForEach(TimerSounds.presets, id: \.self) { minutes in
                    presetChip(minutes)
                }
            }
            .padding(.top, SparkSpacing.sm)

            customDurationRow
                .padding(.top, SparkSpacing.sm)

            Text("1–180 minutes")
                .font(SparkTypography.caption())
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, SparkSpacing.xs)
        }
        .sparkFadeInDown(delay: 0.24)
    }

    private func presetChip(_ minutes: Int) -> some View {
        let active = !timerStore.running && selectedMin == minutes

        return Button {
            selectPreset(minutes)
        } label: {
            VStack(spacing: 0) {
                Text("\(minutes)")
                    .font(SparkTypography.font(.displayBold, size: 18, relativeTo: .body))
                    .foregroundStyle(active ? SparkColors.white : SparkColors.ink)
                Text("min")
                    .font(SparkTypography.font(.body, size: 11, relativeTo: .caption2))
                    .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(active ? SparkColors.peach : SparkColors.card)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
            .sparkSoftShadow()
            .opacity(timerStore.running ? 0.55 : 1)
        }
        .buttonStyle(.plain)
        .disabled(timerStore.running)
        .accessibilityLabel("\(minutes) minutes")
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    private var customDurationRow: some View {
        HStack {
            Text("Custom")
                .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .body))
                .foregroundStyle(SparkColors.ink)

            Spacer()

            HStack(spacing: SparkSpacing.sm) {
                stepButton(systemName: "minus") {
                    stepCustom(-5)
                }

                TextField("", value: $selectedMin, format: .number)
                    .font(SparkTypography.font(.displayBold, size: 20, relativeTo: .title3))
                    .foregroundStyle(SparkColors.ink)
                    .multilineTextAlignment(.center)
                    .frame(minWidth: 54)
                    .keyboardType(.numberPad)
                    .disabled(timerStore.running)
                    .onChange(of: selectedMin) { _, newValue in
                        applyCustomMinutes(newValue)
                    }
                    .accessibilityLabel("Custom minutes")

                stepButton(systemName: "plus") {
                    stepCustom(5)
                }
            }
        }
        .padding(.vertical, SparkSpacing.sm)
        .padding(.horizontal, SparkSpacing.md)
        .background(SparkColors.card)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
        .sparkSoftShadow()
        .opacity(timerStore.running ? 0.55 : 1)
    }

    private func stepButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(SparkColors.peach)
                .frame(width: 40, height: 40)
                .background(SparkColors.peachSoft)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .disabled(timerStore.running)
        .accessibilityLabel(systemName == "minus" ? "Decrease minutes" : "Increase minutes")
    }

    // MARK: - Sounds

    private var soundSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("ALARM SOUND")
                .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 26)

            VStack(spacing: 10) {
                ForEach(TimerSounds.all) { sound in
                    soundRow(sound)
                }
            }
            .padding(.top, SparkSpacing.sm)

            Text("Your chosen chime plays in the app when time's up. If you leave the app, a notification will still ding with your phone's default sound.")
                .font(SparkTypography.caption())
                .foregroundStyle(SparkColors.inkSoft)
                .lineSpacing(6)
                .padding(.top, 10)
        }
        .sparkFadeInDown(delay: 0.3)
    }

    private func soundRow(_ sound: TimerSound) -> some View {
        let selected = sound.id == timerStore.soundId
        let isSilent = sound.url == nil

        return HStack(spacing: SparkSpacing.sm) {
            Button {
                chooseSound(sound.id)
            } label: {
                HStack(spacing: SparkSpacing.sm) {
                    ZStack {
                        Circle()
                            .fill(selected ? SparkColors.peach : SparkColors.peachSoft)
                            .frame(width: 26, height: 26)
                        if selected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(SparkColors.white)
                        }
                    }

                    Text(sound.label)
                        .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .buttonStyle(.plain)
            .accessibilityLabel(sound.label)
            .accessibilityAddTraits(selected ? .isSelected : [])

            if isSilent {
                Image(systemName: "bell.slash")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundStyle(SparkColors.inkSoft)
                    .frame(width: 40, height: 40)
                    .background(SparkColors.peachSoft)
                    .clipShape(Circle())
                    .accessibilityHidden(true)
            } else {
                Button {
                    previewSound(sound.id)
                } label: {
                    Image(systemName: "speaker.wave.2")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(SparkColors.peach)
                        .frame(width: 40, height: 40)
                        .background(SparkColors.peachSoft)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Preview \(sound.label)")
            }
        }
        .padding(.vertical, SparkSpacing.sm)
        .padding(.horizontal, 14)
        .background(SparkColors.card)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
        .overlay {
            if selected {
                RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                    .stroke(SparkColors.peach, lineWidth: 2)
            }
        }
        .sparkSoftShadow()
    }

    // MARK: - Completion

    private var completionSection: some View {
        SparkCard(backgroundColor: SparkColors.peachSoft) {
            VStack(spacing: 0) {
                Text("🎉")
                    .font(.system(size: 44))
                    .accessibilityHidden(true)

                Text("Time's up!")
                    .font(SparkTypography.font(.displayBold, size: 22, relativeTo: .title3))
                    .foregroundStyle(SparkColors.ink)
                    .padding(.top, 6)

                Text("You did it. Stretch, sip some water, and be proud of yourself. 💗")
                    .font(SparkTypography.body())
                    .foregroundStyle(SparkColors.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(7)
                    .padding(.top, 6)

                SparkPrimaryButton(
                    label: "Done",
                    gradient: SparkTheme.gradient(.coral),
                    action: dismissFinish
                )
                .padding(.top, SparkSpacing.md)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, SparkSpacing.section)
        .sparkFadeInDown(delay: 0, duration: 0.35)
        .accessibilityElement(children: .contain)
    }

    // MARK: - Tick engine

    private func startTickingIfNeeded() {
        stopTicking()
        guard timerStore.running, timerStore.endsAt != nil else {
            remaining = timerStore.remainingSeconds()
            return
        }

        tick()
        let timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { _ in
            Task { @MainActor in
                tick()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        tickTimer = timer
    }

    private func stopTicking() {
        tickTimer?.invalidate()
        tickTimer = nil
    }

    @MainActor
    private func tick() {
        guard timerStore.running, timerStore.endsAt != nil else {
            remaining = timerStore.remainingSeconds()
            return
        }

        let left = timerStore.remainingSeconds()
        if left <= 0 {
            remaining = 0
            triggerFinish()
            return
        }
        remaining = left
    }

    @MainActor
    private func triggerFinish() {
        guard !didTriggerFinish else { return }
        didTriggerFinish = true
        finished = true
        stopTicking()
        timerStore.reset()
        scheduledNotificationID = nil

        SparkTimerAudioService.shared.play(soundID: timerStore.soundId)
        SparkHaptics.successNotification()
        startBuzzLoop()
    }

    private func startBuzzLoop() {
        buzzTask?.cancel()
        buzzTask = Task { @MainActor in
            for _ in 0..<8 {
                guard !Task.isCancelled else { return }
                SparkHaptics.heavyImpact()
                try? await Task.sleep(for: .milliseconds(700))
            }
        }
    }

    // MARK: - Controls actions

    private func dismissFinish() {
        finished = false
        didTriggerFinish = false
        remaining = timerStore.remainingSec
        SparkTimerAudioService.shared.stop()
        buzzTask?.cancel()
        buzzTask = nil
        SparkHaptics.lightImpact()
    }

    private func handleStart() {
        SparkHaptics.mediumImpact()
        finished = false
        didTriggerFinish = false
        Task {
            await cancelScheduledNotification()
            let minutes = max(TimerSounds.minMinutes, min(TimerSounds.maxMinutes, selectedMin))
            let seconds = minutes * 60
            let finishAt = Date().addingTimeInterval(TimeInterval(seconds))
            await MainActor.run {
                timerStore.start(durationSec: seconds)
                remaining = seconds
            }
            await scheduleFinishNotification(at: finishAt)
        }
    }

    private func handlePause() {
        SparkHaptics.lightImpact()
        stopTicking()
        timerStore.pause()
        remaining = timerStore.remainingSec
        Task {
            await cancelScheduledNotification()
        }
    }

    private func handleResume() {
        SparkHaptics.mediumImpact()
        finished = false
        didTriggerFinish = false
        let left = timerStore.remainingSec
        timerStore.resume()
        remaining = left
        startTickingIfNeeded()
        Task {
            if left > 0 {
                await scheduleFinishNotification(at: Date().addingTimeInterval(TimeInterval(left)))
            }
        }
    }

    private func handleReset() {
        SparkHaptics.lightImpact()
        finished = false
        didTriggerFinish = false
        SparkTimerAudioService.shared.stop()
        buzzTask?.cancel()
        buzzTask = nil
        stopTicking()
        timerStore.reset()
        remaining = timerStore.remainingSec
        Task {
            await cancelScheduledNotification()
        }
    }

    private func selectPreset(_ minutes: Int) {
        SparkHaptics.lightImpact()
        selectedMin = minutes
        timerStore.setDurationWhileIdle(seconds: minutes * 60)
        remaining = minutes * 60
    }

    private func stepCustom(_ delta: Int) {
        SparkHaptics.lightImpact()
        let next = max(TimerSounds.minMinutes, min(TimerSounds.maxMinutes, selectedMin + delta))
        selectedMin = next
        timerStore.setDurationWhileIdle(seconds: next * 60)
        remaining = next * 60
    }

    private func applyCustomMinutes(_ value: Int) {
        let clamped = max(TimerSounds.minMinutes, min(TimerSounds.maxMinutes, value))
        if clamped != selectedMin {
            selectedMin = clamped
        }
        guard !timerStore.running else { return }
        timerStore.setDurationWhileIdle(seconds: clamped * 60)
        remaining = clamped * 60
    }

    private func previewSound(_ id: String) {
        SparkHaptics.lightImpact()
        SparkTimerAudioService.shared.play(soundID: id)
    }

    private func chooseSound(_ id: String) {
        SparkHaptics.mediumImpact()
        timerStore.setSound(id)
        previewSound(id)
    }

    // MARK: - Notifications

    private func cancelScheduledNotification() async {
        if let scheduledNotificationID {
            await SparkNotificationService.cancelReminder(id: scheduledNotificationID)
            await MainActor.run {
                self.scheduledNotificationID = nil
            }
        }
    }

    private func scheduleFinishNotification(at date: Date) async {
        let granted = await SparkNotificationService.requestPermission()
        guard granted else { return }
        if let id = await SparkNotificationService.scheduleTimerFinish(at: date) {
            await MainActor.run {
                scheduledNotificationID = id
            }
        }
    }
}

#Preview {
    NavigationStack {
        TimerView()
            .environment(TimerStore())
    }
}
