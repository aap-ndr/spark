//
//  DatesContent.swift
//  Spark
//
//  Purpose:
//  Static dates feature copy and styling helpers.
//
//  Responsibilities:
//  • Provides event emoji suggestions and UI constants.
//

import Foundation
import SwiftUI

struct DateCategoryMeta {
    let label: String
    let emoji: String
    let fill: Color
    let accent: Color
    let gradient: SparkGradientPreset
}

struct ReminderChipOption: Identifiable {
    let label: String
    let value: Int
    var id: Int { value }
}

enum DatesContent {
    static let categoryOrder: [DateCategory] = [
        .birthday, .anniversary, .party, .exam, .presentation, .prom, .sleepover, .school, .custom,
    ]

    static let schoolTemplates = [
        "First day of school",
        "Project due",
        "School holiday",
        "Parent–teacher meeting",
        "Field trip",
        "Report card",
    ]

    static let reminderChips: [ReminderChipOption] = [
        ReminderChipOption(label: "Same day", value: 0),
        ReminderChipOption(label: "1 day", value: 1),
        ReminderChipOption(label: "3 days", value: 3),
        ReminderChipOption(label: "1 week", value: 7),
    ]

    static func meta(for category: DateCategory) -> DateCategoryMeta {
        switch category {
        case .birthday:
            return DateCategoryMeta(label: "Birthday", emoji: "🎂", fill: SparkColors.pinkSoft, accent: SparkColors.pink, gradient: .pink)
        case .anniversary:
            return DateCategoryMeta(label: "Anniversary", emoji: "💞", fill: SparkColors.peachSoft, accent: SparkColors.peach, gradient: .coral)
        case .party:
            return DateCategoryMeta(label: "Party", emoji: "🎉", fill: SparkColors.yellowSoft, accent: SparkColors.yellow, gradient: .sunrise)
        case .exam:
            return DateCategoryMeta(label: "Exam", emoji: "📝", fill: SparkColors.skySoft, accent: SparkColors.sky, gradient: .ocean)
        case .presentation:
            return DateCategoryMeta(label: "Presentation", emoji: "🎤", fill: SparkColors.lavenderSoft, accent: SparkColors.lavender, gradient: .lavender)
        case .prom:
            return DateCategoryMeta(label: "Prom", emoji: "👗", fill: SparkColors.pinkSoft, accent: SparkColors.pink, gradient: .berry)
        case .sleepover:
            return DateCategoryMeta(label: "Sleepover", emoji: "🛌", fill: SparkColors.indigoSoft, accent: SparkColors.lavender, gradient: .twilight)
        case .school:
            return DateCategoryMeta(label: "School", emoji: "🎒", fill: SparkColors.mintSoft, accent: SparkColors.mint, gradient: .garden)
        case .custom:
            return DateCategoryMeta(label: "Custom", emoji: "✨", fill: SparkColors.yellowSoft, accent: SparkColors.yellow, gradient: .dream)
        }
    }

    static func displayLabel(for item: ImportantDate) -> String {
        if item.category == .custom, let custom = item.customCategory?.trimmingCharacters(in: .whitespacesAndNewlines), !custom.isEmpty {
            return custom
        }
        return meta(for: item.category).label
    }

    static func titlePlaceholder(for category: DateCategory) -> String {
        switch category {
        case .birthday: return "e.g. Mom's birthday"
        case .anniversary: return "e.g. Our friendiversary"
        case .party: return "e.g. Sofia's party"
        case .prom: return "e.g. Spring prom"
        case .sleepover: return "e.g. Girls' sleepover"
        case .presentation: return "e.g. History presentation"
        case .exam, .school, .custom: return "e.g. Science exam"
        }
    }

    static func defaultRecurrence(for category: DateCategory) -> DateRecurrence {
        category == .birthday || category == .anniversary ? .yearly : .once
    }

    static func toMidnight(_ date: Date) -> Int64 {
        Int64(Calendar.current.startOfDay(for: date).timeIntervalSince1970 * 1000)
    }

    static func formatDate(_ milliseconds: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
        return date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day().year())
    }

    static func formatTime(hour: Int, minute: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let date = Calendar.current.date(from: components) ?? Date()
        return date.formatted(date: .omitted, time: .shortened)
    }

    static func countdownLabel(target: Int64) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let targetDay = calendar.startOfDay(for: Date(timeIntervalSince1970: TimeInterval(target) / 1000))
        let days = Int(round(targetDay.timeIntervalSince(today) / 86_400))

        if days <= 0 { return "today" }
        if days == 1 { return "tomorrow" }
        return "in \(days) days"
    }
}

enum DateReminderScheduler {
    static func computeReminderDate(
        eventDate: Int64,
        daysBefore: Int,
        hour: Int,
        minute: Int
    ) -> Date {
        let base = Date(timeIntervalSince1970: TimeInterval(eventDate) / 1000)
        let shifted = Calendar.current.date(byAdding: .day, value: -daysBefore, to: base) ?? base
        var components = Calendar.current.dateComponents([.year, .month, .day], from: shifted)
        components.hour = hour
        components.minute = minute
        components.second = 0
        return Calendar.current.date(from: components) ?? shifted
    }

    static func settingsForItem(_ item: ImportantDate, base: NotificationSettingsSnapshot) -> NotificationSettingsSnapshot {
        guard let time = item.time else { return base }
        var updated = base
        updated.reminderHour = time.hour
        updated.reminderMinute = time.minute
        return updated
    }

    static func scheduleDateReminder(
        item: ImportantDate,
        settings: NotificationSettingsSnapshot
    ) async -> String? {
        guard settings.enabled else { return nil }
        guard settings.perCategory[item.category] == true else { return nil }

        let occurrence = UpcomingAggregator.nextOccurrence(date: item.date, recurring: item.recurring)
        let fireDate = computeReminderDate(
            eventDate: occurrence,
            daysBefore: item.reminderDaysBefore,
            hour: settings.reminderHour,
            minute: settings.reminderMinute
        )
        guard fireDate.timeIntervalSinceNow > 0 else { return nil }

        let granted = await SparkNotificationService.requestPermission()
        guard granted else { return nil }

        let label = item.category == .custom && item.customCategory?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? item.customCategory!.trimmingCharacters(in: .whitespacesAndNewlines)
            : item.title

        let whenNote: String
        switch item.reminderDaysBefore {
        case 0:
            whenNote = "\(item.title) is today ✨"
        case 1:
            whenNote = "\(item.title) is tomorrow 💗"
        default:
            whenNote = "\(item.title) is in \(item.reminderDaysBefore) days 🌸"
        }

        let body = item.notes?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
            ? item.notes!.trimmingCharacters(in: .whitespacesAndNewlines)
            : whenNote

        return await SparkNotificationService.scheduleReminder(title: label, body: body, date: fireDate)
    }
}
