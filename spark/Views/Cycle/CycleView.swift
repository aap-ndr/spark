//
//  CycleView.swift
//  Spark
//
//  Purpose:
//  Cycle tracking screen.
//
//  Responsibilities:
//  • Logs periods, shows averages, and displays cycle history.
//

import SwiftUI

struct CycleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CycleStore.self) private var cycleStore
    @Environment(AppNavigationCoordinator.self) private var navigation

    @State private var iosPickerOpen = false
    @State private var pickerDate = Date()
    @State private var customOpen = false
    @State private var customText = ""

    private var observedLengths: [Int] {
        CycleHelpers.observedCycleLengths(entries: cycleStore.entries)
    }

    private var observedAvg: Int? {
        CycleHelpers.observedAverage(entries: cycleStore.entries)
    }

    private var isPreset: Bool {
        CycleContent.lengthChoices.contains(cycleStore.averageCycleLength)
    }

    var body: some View {
        ZStack {
            SparkColors.cream.ignoresSafeArea()

            LinearGradient(
                colors: [SparkColors.pinkSoft, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    summarySection
                    logButtonSection
                    averageLengthSection
                    if !observedLengths.isEmpty {
                        cycleHistorySection
                    }
                    loggedPeriodsSection
                    gentleNoteSection
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.bottom, 60)
            }
            .safeAreaPadding(.top, SparkSpacing.sm)
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $iosPickerOpen) {
            periodDatePickerSheet
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button {
                    SparkHaptics.lightImpact()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(SparkColors.inkSoft)
                        Text("Home")
                            .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                            .foregroundStyle(SparkColors.inkSoft)
                    }
                    .frame(minHeight: SparkSpacing.minimumTouchTarget, alignment: .leading)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back to Home")

                Spacer()

                HeaderShortcutsView(color: SparkColors.pink) { route in
                    navigation.homePath.append(route)
                }
            }
            .padding(.bottom, 10)

            Text("My Cycle")
                .sparkTitle()

            Text("A private, gentle place to track your period. Only you can see this. 🌸")
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.inkSoft)
                .lineSpacing(6)
                .padding(.top, 2)
        }
        .sparkFadeInDown(duration: 0.4)
    }

    private var summarySection: some View {
        Group {
            if let lastStart = cycleStore.entries.first?.startDate {
                summaryCard(lastStart: lastStart)
            } else {
                emptySummaryCard
            }
        }
        .sparkFadeInDown(delay: 0.09)
    }

    private func summaryCard(lastStart: Int64) -> some View {
        let status = CycleHelpers.cycleStatus(
            lastStart: lastStart,
            averageCycleLength: cycleStore.averageCycleLength
        )

        return VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: SparkSpacing.xs) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(SparkColors.white)
                Text("WHERE YOU ARE TODAY")
                    .font(SparkTypography.font(.bodyExtra, size: 12, relativeTo: .caption))
                    .foregroundStyle(SparkColors.white)
            }

            Text("Cycle day \(status.cycleDay)")
                .font(SparkTypography.font(.displayBold, size: 30, relativeTo: .largeTitle))
                .foregroundStyle(SparkColors.white)
                .padding(.top, 10)
                .accessibilityLabel("Cycle day \(status.cycleDay)")

            VStack(alignment: .leading, spacing: 2) {
                Text("Next period (estimate)")
                    .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                    .foregroundStyle(SparkColors.white.opacity(0.95))

                Text(CycleHelpers.formatDate(status.nextStart))
                    .font(SparkTypography.font(.displayBold, size: 18, relativeTo: .body))
                    .foregroundStyle(SparkColors.white)

                Text(CycleHelpers.daysUntilLabel(status.daysUntil))
                    .font(SparkTypography.supportive())
                    .foregroundStyle(SparkColors.white.opacity(0.95))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.18))
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
            .padding(.top, SparkSpacing.md)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SparkTheme.gradient(.dream))
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
        .sparkSoftShadow()
        .padding(.top, SparkSpacing.xl)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "Cycle day \(status.cycleDay). Next period estimated \(CycleHelpers.formatDate(status.nextStart)). \(CycleHelpers.daysUntilLabel(status.daysUntil))."
        )
    }

    private var emptySummaryCard: some View {
        SparkCard(backgroundColor: SparkColors.lavenderSoft) {
            VStack(spacing: 0) {
                Image(systemName: "calendar.badge.heart")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(SparkColors.lavender)

                Text("Let's start your cycle log")
                    .font(SparkTypography.font(.displayBold, size: 17, relativeTo: .body))
                    .foregroundStyle(SparkColors.ink)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)

                Text("Tap “Log period start” below and pick the day your period began. Once you've logged one, I'll show your cycle day and a gentle estimate for the next one. 💗")
                    .font(SparkTypography.bodyLarge())
                    .foregroundStyle(SparkColors.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(7)
                    .padding(.top, 6)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, SparkSpacing.xl)
    }

    // MARK: - Log button

    private var logButtonSection: some View {
        SparkPrimaryButton(
            label: "Log period start",
            gradient: SparkTheme.gradient(.pink),
            iconSystemName: "drop.fill",
            iconFilled: true,
            action: openDatePicker
        )
        .padding(.top, SparkSpacing.lg)
        .sparkFadeInDown(delay: 0.15)
    }

    // MARK: - Average length

    private var averageLengthSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Average cycle length")
                .sparkSectionTitle()
                .padding(.top, SparkSpacing.sectionTop)

            Text("Most cycles are 21–35 days. Pick what feels closest, or set your own.")
                .font(SparkTypography.supportive())
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 2)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(CycleContent.lengthChoices, id: \.self) { length in
                        lengthChip(length)
                    }
                    customLengthChip
                }
                .padding(.trailing, SparkSpacing.xs)
            }
            .padding(.top, 14)

            if customOpen {
                customLengthCard
                    .padding(.top, 14)
            }
        }
        .sparkFadeInDown(delay: 0.2)
    }

    private func lengthChip(_ length: Int) -> some View {
        let active = length == cycleStore.averageCycleLength

        return Button {
            applyLength(length)
        } label: {
            Text("\(length) days")
                .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
                .padding(.horizontal, SparkSpacing.lg)
                .padding(.vertical, SparkSpacing.sm)
                .background(active ? SparkColors.lavender : SparkColors.card)
                .clipShape(Capsule())
                .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(length) days")
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    private var customLengthChip: some View {
        Button {
            SparkHaptics.lightImpact()
            customText = String(cycleStore.averageCycleLength)
            customOpen = true
        } label: {
            Text(isPreset ? "Custom…" : "\(cycleStore.averageCycleLength) days ✎")
                .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                .foregroundStyle(!isPreset ? SparkColors.white : SparkColors.inkSoft)
                .padding(.horizontal, SparkSpacing.lg)
                .padding(.vertical, SparkSpacing.sm)
                .background(!isPreset ? SparkColors.lavender : SparkColors.card)
                .clipShape(Capsule())
                .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isPreset ? "Custom cycle length" : "Custom cycle length, \(cycleStore.averageCycleLength) days selected")
    }

    private var customLengthCard: some View {
        SparkCard(backgroundColor: SparkColors.lavenderSoft) {
            VStack(alignment: .leading, spacing: 0) {
                Text("Set your own length")
                    .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(SparkColors.ink)

                Text("Anything from \(CycleContent.minLength) to \(CycleContent.maxLength) days.")
                    .font(SparkTypography.caption())
                    .foregroundStyle(SparkColors.inkSoft)
                    .padding(.top, 2)

                HStack(spacing: 14) {
                    stepperButton(systemImage: "minus") {
                        adjustCustomLength(by: -1)
                    }

                    TextField("28", text: $customText)
                        .font(SparkTypography.font(.displayBold, size: 26, relativeTo: .title))
                        .foregroundStyle(SparkColors.ink)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .padding(.vertical, SparkSpacing.xs)
                        .background(SparkColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        .sparkSoftShadow()
                        .onChange(of: customText) { _, newValue in
                            let filtered = newValue.filter(\.isNumber).prefix(2)
                            if filtered != newValue {
                                customText = String(filtered)
                            }
                        }

                    stepperButton(systemImage: "plus") {
                        adjustCustomLength(by: 1)
                    }
                }
                .padding(.top, 14)

                HStack(spacing: 10) {
                    Button {
                        customOpen = false
                        customText = ""
                    } label: {
                        Text("Cancel")
                            .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                            .foregroundStyle(SparkColors.inkSoft)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(SparkColors.card)
                            .clipShape(Capsule())
                            .sparkSoftShadow()
                    }
                    .buttonStyle(.plain)

                    Button {
                        commitCustomLength()
                    } label: {
                        Text("Save")
                            .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                            .foregroundStyle(SparkColors.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(SparkColors.lavender)
                            .clipShape(Capsule())
                            .sparkSoftShadow()
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 14)
            }
        }
    }

    private func stepperButton(systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(SparkColors.lavender)
                .frame(width: 46, height: 46)
                .background(SparkColors.card)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(systemImage == "minus" ? "Decrease cycle length" : "Increase cycle length")
    }

    // MARK: - Observed history

    private var cycleHistorySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Your cycle history")
                .sparkSectionTitle()
                .padding(.top, SparkSpacing.sectionTop)

            Text("Based on the \(observedLengths.count == 1 ? "gap" : "gaps") between the periods you've logged.")
                .font(SparkTypography.supportive())
                .foregroundStyle(SparkColors.inkSoft)
                .lineSpacing(7)
                .padding(.top, 2)

            SparkCard(backgroundColor: SparkColors.lavenderSoft) {
                VStack(alignment: .leading, spacing: 0) {
                    if let observedAvg {
                        HStack(alignment: .lastTextBaseline, spacing: SparkSpacing.xs) {
                            Text("\(observedAvg)")
                                .font(SparkTypography.font(.displayBold, size: 30, relativeTo: .largeTitle))
                                .foregroundStyle(SparkColors.ink)
                            Text("days on average")
                                .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                                .foregroundStyle(SparkColors.inkSoft)
                                .padding(.bottom, 6)
                        }
                    }

                    VStack(spacing: SparkSpacing.xs) {
                        ForEach(Array(observedLengths.prefix(6).enumerated()), id: \.offset) { _, length in
                            observedBarRow(length: length, maxLength: max(observedLengths.prefix(6).max() ?? 0, CycleContent.maxLength))
                        }
                    }
                    .padding(.top, 14)

                    if observedLengths.count >= 2, let observedAvg {
                        if observedAvg == cycleStore.averageCycleLength {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(SparkColors.mint)
                                Text("Predictions use your average")
                                    .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                                    .foregroundStyle(SparkColors.inkSoft)
                            }
                            .padding(.top, 14)
                        } else {
                            Button {
                                applyLength(observedAvg)
                            } label: {
                                HStack(spacing: SparkSpacing.xs) {
                                    Image(systemName: "sparkles")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(SparkColors.white)
                                    Text("Use your average (\(observedAvg) days)")
                                        .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                                        .foregroundStyle(SparkColors.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 13)
                                .background(SparkColors.lavender)
                                .clipShape(Capsule())
                                .sparkSoftShadow()
                            }
                            .buttonStyle(.plain)
                            .padding(.top, 14)
                            .accessibilityLabel("Use your average of \(observedAvg) days")
                        }
                    } else {
                        Text("Log one more period and I can suggest using your own average for predictions. 💗")
                            .font(SparkTypography.caption())
                            .foregroundStyle(SparkColors.inkSoft)
                            .lineSpacing(6)
                            .padding(.top, SparkSpacing.sm)
                    }
                }
            }
            .padding(.top, 14)
        }
        .sparkFadeInDown(delay: 0.225)
    }

    private func observedBarRow(length: Int, maxLength: Int) -> some View {
        let fraction = max(0.12, Double(length) / Double(maxLength))

        return HStack(spacing: 10) {
            GeometryReader { geometry in
                Capsule()
                    .fill(SparkColors.lavender)
                    .frame(width: geometry.size.width * fraction, height: 20)
                    .frame(maxHeight: .infinity, alignment: .center)
            }
            .frame(height: 20)

            Text("\(length) days")
                .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .frame(width: 58, alignment: .trailing)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(length) days")
    }

    // MARK: - Logged periods

    private var loggedPeriodsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Logged periods")
                .sparkSectionTitle()
                .padding(.top, SparkSpacing.sectionTop)

            if cycleStore.entries.isEmpty {
                SparkCard(backgroundColor: SparkColors.pinkSoft) {
                    Text("Nothing logged yet. Your period history will appear here. 🌷")
                        .font(SparkTypography.bodyLarge())
                        .foregroundStyle(SparkColors.inkSoft)
                        .multilineTextAlignment(.center)
                        .lineSpacing(7)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 14)
            } else {
                VStack(spacing: 10) {
                    ForEach(Array(cycleStore.entries.enumerated()), id: \.element.id) { index, entry in
                        let gap = index < cycleStore.entries.count - 1
                            ? CycleHelpers.daysBetween(entry.startDate, cycleStore.entries[index + 1].startDate)
                            : nil
                        CycleHistoryRow(
                            entry: entry,
                            gap: gap,
                            onDelete: {
                                SparkHaptics.mediumImpact()
                                cycleStore.removeEntry(id: entry.id)
                            }
                        )
                    }
                }
                .padding(.top, 14)
            }
        }
        .sparkFadeInDown(delay: 0.25)
    }

    // MARK: - Gentle note

    private var gentleNoteSection: some View {
        SparkCard(backgroundColor: SparkColors.mintSoft) {
            VStack(alignment: .leading, spacing: 0) {
                Text("A GENTLE NOTE")
                    .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                    .foregroundStyle(SparkColors.mint)

                Text("These predictions are just estimates — real cycles naturally shift from month to month, especially in your teens. If something ever worries you, a parent or doctor is a great person to talk to. 💗")
                    .font(SparkTypography.bodyLarge())
                    .foregroundStyle(SparkColors.ink)
                    .lineSpacing(8)
                    .padding(.top, 6)
            }
        }
        .padding(.top, SparkSpacing.xxl)
        .sparkFadeInDown(delay: 0.3)
    }

    // MARK: - Date picker sheet

    private var periodDatePickerSheet: some View {
        VStack(spacing: 0) {
            HStack {
                Text("When did it start?")
                    .font(SparkTypography.font(.displayBold, size: 20, relativeTo: .title3))
                    .foregroundStyle(SparkColors.ink)
                Spacer()
                Button {
                    iosPickerOpen = false
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(SparkColors.inkSoft)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close date picker")
            }

            DatePicker(
                "Period start date",
                selection: $pickerDate,
                in: ...Date(),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .padding(.top, SparkSpacing.xs)

            SparkPrimaryButton(
                label: "Save period start",
                gradient: SparkTheme.gradient(.pink),
                iconSystemName: "checkmark",
                action: {
                    commitDate(pickerDate)
                    iosPickerOpen = false
                }
            )
            .padding(.top, SparkSpacing.md)
        }
        .padding(.horizontal, SparkSpacing.section)
        .padding(.top, SparkSpacing.section)
        .padding(.bottom, 44)
        .background(SparkColors.cream)
    }

    // MARK: - Actions

    private func openDatePicker() {
        SparkHaptics.lightImpact()
        pickerDate = Date()
        iosPickerOpen = true
    }

    private func commitDate(_ date: Date) {
        cycleStore.logPeriod(startDate: CycleHelpers.toMidnight(date))
        SparkHaptics.successNotification()
    }

    private func applyLength(_ length: Int) {
        cycleStore.setAverageCycleLength(CycleContent.clampLength(length))
        SparkHaptics.lightImpact()
    }

    private func adjustCustomLength(by delta: Int) {
        let current = Int(customText) ?? cycleStore.averageCycleLength
        let next = CycleContent.clampLength(current + delta)
        customText = String(next)
        SparkHaptics.lightImpact()
    }

    private func commitCustomLength() {
        if let parsed = Int(customText) {
            applyLength(parsed)
        }
        customOpen = false
        customText = ""
    }
}

private struct CycleHistoryRow: View {
    let entry: CycleEntry
    let gap: Int?
    let onDelete: () -> Void

    var body: some View {
        SparkCard {
            HStack(spacing: SparkSpacing.sm) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(SparkColors.pink)
                    .frame(width: 44, height: 44)
                    .background(SparkColors.pinkSoft)
                    .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(CycleHelpers.formatDate(entry.startDate))
                        .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)

                    if let gap {
                        Text("\(gap) \(gap == 1 ? "day" : "days") since the one before")
                            .font(SparkTypography.caption())
                            .foregroundStyle(SparkColors.inkSoft)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(SparkColors.inkSoft)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Delete period logged on \(CycleHelpers.formatDate(entry.startDate))")
            }
        }
        .accessibilityElement(children: .contain)
    }
}

#Preview {
    NavigationStack {
        CycleView()
            .environment(CycleStore())
            .environment(AppNavigationCoordinator())
    }
}
