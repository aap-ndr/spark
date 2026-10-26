//
//  Reminder.swift
//  Spark
//
//  Purpose:
//  Reminder model with scheduling and recurrence fields.
//
//  Responsibilities:
//  • Captures reminder content, timing, and notification metadata.
//

import Foundation
import SwiftUI

enum ReminderScheduleType: String, Codable {
    case oneTime
    case everyDay
    case selectedDays
}

struct ReminderTime: Codable, Equatable {
    let hour: Int
    let minute: Int
}

struct Reminder: Codable, Equatable, Identifiable {
    let id: String
    var title: String
    var emoji: String?
    var categoryId: String?
    var time: ReminderTime
    var scheduleType: ReminderScheduleType
    /// Local start-of-day epoch milliseconds for the schedule date.
    var startDate: Int64
    var weekdays: [Int]?
    var enabled: Bool
    var notificationIds: [String]
    let createdAt: Int64

    enum CodingKeys: String, CodingKey {
        case id, title, emoji, categoryId, time, weekdays, enabled, notificationIds, createdAt
        case scheduleType
        case startDate
        case legacyRepeat = "repeat"
    }

    init(
        id: String,
        title: String,
        emoji: String?,
        categoryId: String?,
        time: ReminderTime,
        scheduleType: ReminderScheduleType,
        startDate: Int64,
        weekdays: [Int]?,
        enabled: Bool,
        notificationIds: [String],
        createdAt: Int64
    ) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.categoryId = categoryId
        self.time = time
        self.scheduleType = scheduleType
        self.startDate = startDate
        self.weekdays = weekdays
        self.enabled = enabled
        self.notificationIds = notificationIds
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        emoji = try container.decodeIfPresent(String.self, forKey: .emoji)
        categoryId = try container.decodeIfPresent(String.self, forKey: .categoryId)
        time = try container.decode(ReminderTime.self, forKey: .time)
        weekdays = try container.decodeIfPresent([Int].self, forKey: .weekdays)
        enabled = try container.decode(Bool.self, forKey: .enabled)
        notificationIds = try container.decodeIfPresent([String].self, forKey: .notificationIds) ?? []
        createdAt = try container.decode(Int64.self, forKey: .createdAt)

        if let decodedScheduleType = try container.decodeIfPresent(ReminderScheduleType.self, forKey: .scheduleType) {
            scheduleType = decodedScheduleType
        } else if let legacyRepeat = try container.decodeIfPresent(String.self, forKey: .legacyRepeat) {
            switch legacyRepeat {
            case "daily":
                scheduleType = .everyDay
            case "weekly":
                scheduleType = .selectedDays
            default:
                scheduleType = .everyDay
            }
        } else {
            scheduleType = .everyDay
        }

        startDate = try container.decodeIfPresent(Int64.self, forKey: .startDate)
            ?? ReminderScheduleCalculator.startOfDayMs()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(emoji, forKey: .emoji)
        try container.encodeIfPresent(categoryId, forKey: .categoryId)
        try container.encode(time, forKey: .time)
        try container.encode(scheduleType, forKey: .scheduleType)
        try container.encode(startDate, forKey: .startDate)
        try container.encodeIfPresent(weekdays, forKey: .weekdays)
        try container.encode(enabled, forKey: .enabled)
        try container.encode(notificationIds, forKey: .notificationIds)
        try container.encode(createdAt, forKey: .createdAt)
    }
}

struct ReminderCategory: Codable, Equatable, Identifiable {
    let id: String
    var label: String
    var emoji: String
    var colorHex: UInt

    var color: Color {
        Color(sparkHex: colorHex)
    }
}

struct ReminderInput {
    let title: String
    let emoji: String?
    let categoryId: String?
    let time: ReminderTime
    let scheduleType: ReminderScheduleType
    let startDate: Int64
    let weekdays: [Int]?
    let enabled: Bool
}

enum ReminderCategoryDefaults {
    static let otherCategoryID = "cat-other"

    static let seeded: [ReminderCategory] = [
        ReminderCategory(id: "cat-health", label: "Health & Meds", emoji: "💊", colorHex: 0xD61E6C),
        ReminderCategory(id: "cat-nourishment", label: "Nourishment", emoji: "🥤", colorHex: 0xE0951C),
        ReminderCategory(id: "cat-family", label: "Family", emoji: "👨‍👩‍👧", colorHex: 0xE84D52),
        ReminderCategory(id: "cat-selfcare", label: "Self-care", emoji: "🧘", colorHex: 0x0F9E88),
        ReminderCategory(id: "cat-hydration", label: "Hydration", emoji: "💧", colorHex: 0x276FDB),
        ReminderCategory(id: "cat-other", label: "Other", emoji: "✨", colorHex: 0x6B26D6),
    ]
}
