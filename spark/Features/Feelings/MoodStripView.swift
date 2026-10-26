//
//  MoodStripView.swift
//  Spark
//
//  Purpose:
//  Horizontal mood selection strip.
//
//  Responsibilities:
//  • Renders selectable mood chips for check-ins.
//

import SwiftUI

struct MoodStripView: View {
    let entries: [MoodEntry]

    private var days: [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: offset - 6, to: today)
        }
    }

    var body: some View {
        HStack {
            ForEach(Array(days.enumerated()), id: \.offset) { _, day in
                dayColumn(for: day)
                if day != days.last {
                    Spacer(minLength: 0)
                }
            }
        }
    }

    private func dayColumn(for day: Date) -> some View {
        let entry = moodForDay(day)
        let weekday = day.formatted(.dateTime.weekday(.narrow))

        return VStack(spacing: SparkSpacing.xs) {
            ZStack {
                Circle()
                    .fill(entry.map { FeelingsContent.moodDotColor(for: $0.mood) } ?? SparkColors.lavenderSoft)
                    .frame(width: 26, height: 26)

                if let entry {
                    Text(entry.emoji)
                        .font(.system(size: 12))
                }
            }

            Text(weekday)
                .font(SparkTypography.font(.bodyBold, size: 11, relativeTo: .caption2))
                .foregroundStyle(SparkColors.inkSoft)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(dayAccessibilityLabel(day: day, entry: entry))
    }

    private func moodForDay(_ day: Date) -> MoodEntry? {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: day)
        guard let end = calendar.date(byAdding: .day, value: 1, to: start) else { return nil }
        let startMs = Int64(start.timeIntervalSince1970 * 1000)
        let endMs = Int64(end.timeIntervalSince1970 * 1000)
        return entries.first { $0.createdAt >= startMs && $0.createdAt < endMs }
    }

    private func dayAccessibilityLabel(day: Date, entry: MoodEntry?) -> String {
        let dayName = day.formatted(.dateTime.weekday(.wide))
        if let entry {
            return "\(dayName), \(entry.mood)"
        }
        return "\(dayName), no check-in"
    }
}
