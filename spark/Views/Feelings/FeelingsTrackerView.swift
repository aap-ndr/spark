//
//  FeelingsTrackerView.swift
//  Spark
//
//  Purpose:
//  Feelings history and mood trend view.
//
//  Responsibilities:
//  • Displays past check-ins and mood patterns.
//

import SwiftUI

struct FeelingsTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FeelingsStore.self) private var feelingsStore

    private var recentEntries: [MoodEntry] {
        Array(feelingsStore.entries.prefix(5))
    }

    private var todayEntries: [MoodEntry] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let startMs = Int64(start.timeIntervalSince1970 * 1000)
        return feelingsStore.entries.filter { $0.createdAt >= startMs }
    }

    var body: some View {
        ZStack {
            SparkColors.cream.ignoresSafeArea()

            LinearGradient(
                colors: [SparkColors.pinkSoft, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    backButton

                    Text("Your feelings tracker")
                        .sparkTitle()
                        .padding(.top, 10)

                    Text("A gentle look back at how you've been feeling. 🌷")
                        .font(SparkTypography.body())
                        .foregroundStyle(SparkColors.inkSoft)
                        .lineSpacing(6)
                        .padding(.top, 2)

                    if !todayEntries.isEmpty {
                        todaySection
                    }

                    weekSection
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.bottom, 60)
            }
            .safeAreaPadding(.top, SparkSpacing.md)
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var backButton: some View {
        Button {
            SparkHaptics.lightImpact()
            dismiss()
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(SparkColors.inkSoft)
                Text("Feelings")
                    .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                    .foregroundStyle(SparkColors.inkSoft)
            }
            .frame(minHeight: SparkSpacing.minimumTouchTarget, alignment: .leading)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Back to Feelings")
        .sparkFadeInDown(duration: 0.4)
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Today's check-ins")
                    .sparkSectionTitle()
                Spacer()
                Text("\(todayEntries.count) today")
                    .font(SparkTypography.font(.bodyExtra, size: 12, relativeTo: .caption))
                    .foregroundStyle(SparkColors.pink)
                    .padding(.horizontal, SparkSpacing.sm)
                    .padding(.vertical, SparkSpacing.xxs)
                    .background(SparkColors.pinkSoft)
                    .clipShape(Capsule())
            }
            .padding(.top, 26)

            SparkCard {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(todayEntries.enumerated()), id: \.element.id) { index, entry in
                        todayTimelineRow(entry: entry, showsRail: index < todayEntries.count - 1)
                            .padding(.top, index == 0 ? 0 : 14)
                    }
                }
            }
            .padding(.top, 14)
        }
        .sparkFadeInDown(delay: 0.1)
    }

    private func todayTimelineRow(entry: MoodEntry, showsRail: Bool) -> some View {
        HStack(alignment: .top, spacing: SparkSpacing.sm) {
            VStack(spacing: 4) {
                Circle()
                    .fill(FeelingsContent.moodDotColor(for: entry.mood))
                    .frame(width: 12, height: 12)
                    .padding(.top, 4)

                if showsRail {
                    Rectangle()
                        .fill(SparkColors.lavenderSoft)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 20)

            VStack(alignment: .leading, spacing: 3) {
                HStack(spacing: SparkSpacing.xs) {
                    Text(entry.emoji)
                        .font(.system(size: 22))
                    Text(entry.mood)
                        .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                    Spacer(minLength: 0)
                    Text(entry.createdAtDate, format: .dateTime.hour().minute())
                        .font(SparkTypography.caption())
                        .foregroundStyle(SparkColors.inkSoft)
                }

                if let note = entry.note, !note.isEmpty {
                    Text(note)
                        .font(SparkTypography.supportive())
                        .foregroundStyle(SparkColors.inkSoft)
                        .lineSpacing(6)
                }
            }
        }
    }

    private var weekSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Your week")
                .sparkSectionTitle()
                .padding(.top, SparkSpacing.sectionTop)

            SparkCard {
                MoodStripView(entries: feelingsStore.entries)
            }
            .padding(.top, 14)

            if recentEntries.isEmpty {
                SparkCard(backgroundColor: SparkColors.lavenderSoft) {
                    Text("Your check-ins will show up here. Head back and tap a feeling to add your first one. 🌷")
                        .font(SparkTypography.bodyLarge())
                        .foregroundStyle(SparkColors.inkSoft)
                        .multilineTextAlignment(.center)
                        .lineSpacing(7)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 14)
            } else {
                VStack(spacing: 10) {
                    ForEach(recentEntries) { entry in
                        recentEntryCard(entry)
                    }
                }
                .padding(.top, 14)
            }
        }
        .sparkFadeInDown(delay: 0.16)
    }

    private func recentEntryCard(_ entry: MoodEntry) -> some View {
        SparkCard {
            HStack(alignment: .top, spacing: SparkSpacing.sm) {
                Text(entry.emoji)
                    .font(.system(size: 30))

                VStack(alignment: .leading, spacing: 2) {
                    intensityLabel(for: entry)

                    if let note = entry.note, !note.isEmpty {
                        Text(note)
                            .font(SparkTypography.supportive())
                            .foregroundStyle(SparkColors.inkSoft)
                    }

                    Text(entry.createdAtDate, format: .dateTime.weekday(.abbreviated).hour().minute())
                        .font(SparkTypography.caption())
                        .foregroundStyle(SparkColors.inkSoft)
                        .padding(.top, 2)
                }
            }
        }
    }

    private func intensityLabel(for entry: MoodEntry) -> some View {
        HStack(spacing: 0) {
            Text("\(entry.mood) · ")
                .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                .foregroundStyle(SparkColors.ink)
            Text(String(repeating: "●", count: entry.intensity))
                .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                .foregroundStyle(SparkColors.lavender)
            Text(String(repeating: "●", count: max(0, 5 - entry.intensity)))
                .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                .foregroundStyle(SparkColors.lavenderSoft)
        }
        .accessibilityLabel("\(entry.mood), intensity \(entry.intensity) of 5")
    }
}

private extension MoodEntry {
    var createdAtDate: Date {
        Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000)
    }
}

#Preview {
    NavigationStack {
        FeelingsTrackerView()
            .environment(FeelingsStore())
    }
}
