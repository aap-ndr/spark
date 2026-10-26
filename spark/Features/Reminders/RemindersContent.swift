//
//  RemindersContent.swift
//  Spark
//
//  Purpose:
//  Reminder scheduling helpers and static copy.
//
//  Responsibilities:
//  • Builds recurrence rules and notification payloads.
//  • Provides reminder UI constants and formatting helpers.
//

import Foundation

enum RemindersContent {
    static let dayLetters = ["S", "M", "T", "W", "T", "F", "S"]
    static let dayShort = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    static let categoryEmojiPresets = [
        "💊", "🥤", "👨‍👩‍👧", "🧘", "💧", "📞", "📚", "🏃", "🐾", "🌸", "☀️", "✨",
    ]

    static func formatTime(hour: Int, minute: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        let date = Calendar.current.date(from: components) ?? Date()
        return date.formatted(date: .omitted, time: .shortened)
    }

    static func formatStartDay(_ startDateMs: Int64) -> String {
        let date = ReminderScheduleCalculator.date(fromStartDayMs: startDateMs)
        return date.formatted(.dateTime.month(.abbreviated).day())
    }

    static func scheduleLabel(for reminder: Reminder) -> String {
        let time = formatTime(hour: reminder.time.hour, minute: reminder.time.minute)
        let starts = formatStartDay(reminder.startDate)
        let futureStart = ReminderScheduleCalculator.isStartDateInFuture(reminder.startDate)

        switch reminder.scheduleType {
        case .oneTime:
            return "Once · \(starts) at \(time)"
        case .everyDay:
            if futureStart {
                return "Every day · \(time) · Starts \(starts)"
            }
            return "Every day · \(time)"
        case .selectedDays:
            let days = (reminder.weekdays ?? []).sorted()
            if days.isEmpty {
                return "Weekly at \(time) — pick some days"
            }
            if days.count == 7 {
                if futureStart {
                    return "Every day · \(time) · Starts \(starts)"
                }
                return "Every day · \(time)"
            }
            let labels = days.map { dayShort[$0] }.joined(separator: ", ")
            if futureStart {
                return "\(labels) · \(time) · Starts \(starts)"
            }
            return "\(labels) · \(time)"
        }
    }
}

enum ReminderScheduleCalculator {
    static func startOfDayMs(for date: Date = Date()) -> Int64 {
        let start = Calendar.current.startOfDay(for: date)
        return Int64(start.timeIntervalSince1970 * 1000)
    }

    static func date(fromStartDayMs ms: Int64) -> Date {
        Date(timeIntervalSince1970: TimeInterval(ms) / 1000)
    }

    static func combine(startDayMs: Int64, time: ReminderTime) -> Date {
        combine(startDay: date(fromStartDayMs: startDayMs), time: time)
    }

    static func combine(startDay: Date, time: ReminderTime) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: startDay)
        components.hour = time.hour
        components.minute = time.minute
        components.second = 0
        return Calendar.current.date(from: components) ?? startDay
    }

    static func isStartDateInFuture(_ startDateMs: Int64) -> Bool {
        let calendar = Calendar.current
        let startDay = calendar.startOfDay(for: date(fromStartDayMs: startDateMs))
        let today = calendar.startOfDay(for: Date())
        return startDay > today
    }

    static func jsWeekday(for date: Date) -> Int {
        Calendar.current.component(.weekday, from: date) - 1
    }

    static func firstOccurrence(
        scheduleType: ReminderScheduleType,
        startDateMs: Int64,
        time: ReminderTime,
        weekdays: [Int]?
    ) -> Date? {
        let calendar = Calendar.current
        let startDay = date(fromStartDayMs: startDateMs)
        let now = Date()

        switch scheduleType {
        case .oneTime:
            return combine(startDay: startDay, time: time)
        case .everyDay:
            var candidate = combine(startDay: startDay, time: time)
            while candidate < now {
                guard let next = calendar.date(byAdding: .day, value: 1, to: candidate) else { break }
                candidate = next
            }
            return candidate
        case .selectedDays:
            guard let weekdays, !weekdays.isEmpty else { return nil }
            var searchDay = startDay
            for _ in 0..<400 {
                if weekdays.contains(jsWeekday(for: searchDay)) {
                    let candidate = combine(startDay: searchDay, time: time)
                    if candidate >= now {
                        return candidate
                    }
                }
                guard let next = calendar.date(byAdding: .day, value: 1, to: searchDay) else { break }
                searchDay = next
            }
            return nil
        }
    }
}

enum ReminderScheduler {
    static func schedule(
        for reminder: Reminder,
        setNotificationIds: (String, [String]) -> Void
    ) async -> Bool {
        if !reminder.notificationIds.isEmpty {
            await SparkNotificationService.cancelReminders(ids: reminder.notificationIds)
            setNotificationIds(reminder.id, [])
        }

        guard reminder.enabled else { return false }

        let granted = await SparkNotificationService.requestPermission()
        guard granted else { return true }

        let title = reminder.emoji.map { "\($0) \(reminder.title)" } ?? reminder.title
        let body = "A gentle reminder from Spark 💗"
        var ids: [String] = []

        switch reminder.scheduleType {
        case .oneTime:
            if let fireDate = ReminderScheduleCalculator.firstOccurrence(
                scheduleType: .oneTime,
                startDateMs: reminder.startDate,
                time: reminder.time,
                weekdays: nil
            ), fireDate > Date(),
               let id = await SparkNotificationService.scheduleReminder(title: title, body: body, date: fireDate) {
                ids.append(id)
            }
        case .everyDay:
            if ReminderScheduleCalculator.isStartDateInFuture(reminder.startDate) {
                if let fireDate = ReminderScheduleCalculator.firstOccurrence(
                    scheduleType: .everyDay,
                    startDateMs: reminder.startDate,
                    time: reminder.time,
                    weekdays: nil
                ), fireDate > Date(),
                   let id = await SparkNotificationService.scheduleReminder(title: title, body: body, date: fireDate) {
                    ids.append(id)
                }
            } else if let id = await SparkNotificationService.scheduleDailyReminder(
                title: title,
                body: body,
                hour: reminder.time.hour,
                minute: reminder.time.minute
            ) {
                ids.append(id)
            }
        case .selectedDays:
            if ReminderScheduleCalculator.isStartDateInFuture(reminder.startDate) {
                if let fireDate = ReminderScheduleCalculator.firstOccurrence(
                    scheduleType: .selectedDays,
                    startDateMs: reminder.startDate,
                    time: reminder.time,
                    weekdays: reminder.weekdays
                ), fireDate > Date(),
                   let id = await SparkNotificationService.scheduleReminder(title: title, body: body, date: fireDate) {
                    ids.append(id)
                }
            } else {
                for weekday in reminder.weekdays ?? [] {
                    if let id = await SparkNotificationService.scheduleWeeklyReminder(
                        title: title,
                        body: body,
                        jsWeekday: weekday,
                        hour: reminder.time.hour,
                        minute: reminder.time.minute
                    ) {
                        ids.append(id)
                    }
                }
            }
        }

        setNotificationIds(reminder.id, ids)
        return false
    }

    /// Re-schedule recurring reminders whose start date has arrived so repeating triggers replace the initial one-off.
    static func refreshRecurringSchedules(in store: RemindersStore) async {
        for reminder in store.reminders where reminder.enabled && reminder.scheduleType != .oneTime {
            guard !ReminderScheduleCalculator.isStartDateInFuture(reminder.startDate) else { continue }
            _ = await schedule(for: reminder) { id, ids in
                store.setNotificationIds(id: id, notificationIds: ids)
            }
        }
    }
}
