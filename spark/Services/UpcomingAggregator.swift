//
//  UpcomingAggregator.swift
//  Spark
//
//  Purpose:
//  Home screen upcoming items aggregator.
//
//  Responsibilities:
//  • Combines dates, quests, cycle, and reminders into one feed.
//  • Formats relative timing labels for display.
//

import Foundation

enum UpcomingAggregator {
    private static let dayMilliseconds: Int64 = 86_400_000

    private static let eventEmoji: [DateCategory: String] = [
        .birthday: "🎂",
        .anniversary: "💞",
        .party: "🎉",
        .exam: "📝",
        .presentation: "🎤",
        .prom: "👗",
        .sleepover: "🛌",
        .school: "🎒",
        .custom: "✨",
    ]

    static func whenLabel(_ milliseconds: Int64) -> String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
        let targetDay = calendar.startOfDay(for: target)
        let days = Int(round(targetDay.timeIntervalSince(today) / 86_400))

        let formatter = DateFormatter()
        formatter.timeStyle = .short
        let timeString = formatter.string(from: target)
        let hasTime = calendar.component(.hour, from: target) != 0
            || calendar.component(.minute, from: target) != 0

        if days < 0 { return "past" }
        if days == 0 { return hasTime ? "Today \(timeString)" : "Today" }
        if days == 1 { return hasTime ? "Tomorrow \(timeString)" : "Tomorrow" }
        if days < 7 { return "in \(days) days" }

        formatter.dateFormat = "MMM d"
        return formatter.string(from: target)
    }

    static func nextPeriodDate(entries: [CycleEntry], averageCycleLength: Int) -> Int64? {
        guard let latest = entries.map(\.startDate).max() else { return nil }
        let cycle = averageCycleLength > 0 ? averageCycleLength : 28
        var next = latest + Int64(cycle) * dayMilliseconds
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        while startOfDay(next) < startOfDay(now) {
            next += Int64(cycle) * dayMilliseconds
        }
        return next
    }

    private static func startOfDay(_ milliseconds: Int64) -> Int64 {
        let date = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
        return Int64(Calendar.current.startOfDay(for: date).timeIntervalSince1970 * 1000)
    }

    private static func isUpcoming(when: Int64, hasSpecificTime: Bool, now: Int64, horizon: Int64) -> Bool {
        if hasSpecificTime {
            return when >= now && when <= horizon
        }
        let whenDay = startOfDay(when)
        let nowDay = startOfDay(now)
        return whenDay >= nowDay && whenDay <= horizon
    }

    static func nextOccurrence(date: Int64, recurring: DateRecurrence) -> Int64 {
        if recurring == .once { return date }

        let source = Date(timeIntervalSince1970: TimeInterval(date) / 1000)
        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        var components = calendar.dateComponents([.year, .month, .day], from: now)
        let sourceComponents = calendar.dateComponents([.month, .day], from: source)
        components.month = sourceComponents.month
        components.day = sourceComponents.day
        components.hour = 0
        components.minute = 0
        components.second = 0

        guard var candidate = calendar.date(from: components) else { return date }
        if candidate < today {
            components.year = (components.year ?? now.year) + 1
            candidate = calendar.date(from: components) ?? candidate
        }
        return Int64(candidate.timeIntervalSince1970 * 1000)
    }

    static func nextReminderOccurrence(for reminder: Reminder, now: Date = Date()) -> Int64? {
        guard reminder.enabled else { return nil }

        guard let occurrence = ReminderScheduleCalculator.firstOccurrence(
            scheduleType: reminder.scheduleType,
            startDateMs: reminder.startDate,
            time: reminder.time,
            weekdays: reminder.weekdays
        ), occurrence > now else {
            return nil
        }

        return Int64(occurrence.timeIntervalSince1970 * 1000)
    }

    static func aggregateUpcoming(
        dates: [ImportantDate],
        quests: [Quest],
        cycleEntries: [CycleEntry],
        reminders: [Reminder] = [],
        averageCycleLength: Int,
        windowDays: Int = 30,
        limit: Int = 20,
        now: Int64 = Int64(Date().timeIntervalSince1970 * 1000)
    ) -> [UpcomingItem] {
        let horizon = now + Int64(windowDays) * dayMilliseconds
        var items: [UpcomingItem] = []

        for date in dates {
            let occurrence = nextOccurrence(date: date.date, recurring: date.recurring)
            let when: Int64
            if let time = date.time {
                var components = Calendar.current.dateComponents(
                    [.year, .month, .day],
                    from: Date(timeIntervalSince1970: TimeInterval(occurrence) / 1000)
                )
                components.hour = time.hour
                components.minute = time.minute
                components.second = 0
                when = Int64((Calendar.current.date(from: components) ?? Date()).timeIntervalSince1970 * 1000)
            } else {
                when = occurrence
            }

            guard isUpcoming(when: when, hasSpecificTime: date.time != nil, now: now, horizon: horizon) else { continue }

            items.append(
                UpcomingItem(
                    id: "event-\(date.id)",
                    source: .event,
                    emoji: eventEmoji[date.category] ?? "✨",
                    title: date.title,
                    when: when,
                    route: .dates
                )
            )
        }

        if let period = nextPeriodDate(entries: cycleEntries, averageCycleLength: averageCycleLength),
           isUpcoming(when: period, hasSpecificTime: false, now: now, horizon: horizon) {
            items.append(
                UpcomingItem(
                    id: "cycle-next",
                    source: .cycle,
                    emoji: "🩸",
                    title: "Period expected",
                    when: period,
                    route: .cycle
                )
            )
        }

        for quest in quests {
            guard let remindAt = quest.remindAt, remindAt >= now, remindAt <= horizon else { continue }
            items.append(
                UpcomingItem(
                    id: "quest-\(quest.id)",
                    source: .quest,
                    emoji: quest.emoji.isEmpty ? "✅" : quest.emoji,
                    title: quest.title,
                    when: remindAt,
                    route: .quests
                )
            )
        }

        let nowDate = Date(timeIntervalSince1970: TimeInterval(now) / 1000)
        for reminder in reminders {
            guard let when = nextReminderOccurrence(for: reminder, now: nowDate),
                  isUpcoming(when: when, hasSpecificTime: true, now: now, horizon: horizon) else { continue }

            items.append(
                UpcomingItem(
                    id: "reminder-\(reminder.id)-\(when)",
                    source: .reminder,
                    emoji: reminder.emoji ?? "🔔",
                    title: reminder.title,
                    when: when,
                    route: .reminders
                )
            )
        }

        return items.sorted { $0.when < $1.when }.prefix(limit).map { $0 }
    }
}

private extension Date {
    var year: Int {
        Calendar.current.component(.year, from: self)
    }
}
