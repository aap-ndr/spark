//
//  RemindersStore.swift
//  Spark
//
//  Purpose:
//  Reminder list persistence and scheduling hooks.
//
//  Responsibilities:
//  • Adds, updates, completes, and removes reminders.
//

import Foundation
import Observation

@Observable
final class RemindersStore {
    private struct Payload: Codable {
        var reminders: [Reminder]
    }

    private(set) var reminders: [Reminder] = []

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        reminders = Self.load(from: userDefaults, decoder: decoder) ?? []
    }

    func reminder(id: String) -> Reminder? {
        reminders.first { $0.id == id }
    }

    @discardableResult
    func addReminder(_ input: ReminderInput) -> Reminder {
        let reminder = Reminder(
            id: Self.generateID(),
            title: input.title.trimmingCharacters(in: .whitespacesAndNewlines),
            emoji: input.emoji,
            categoryId: input.categoryId,
            time: input.time,
            scheduleType: input.scheduleType,
            startDate: input.startDate,
            weekdays: input.scheduleType == .selectedDays ? (input.weekdays ?? []) : nil,
            enabled: input.enabled,
            notificationIds: [],
            createdAt: Int64(Date().timeIntervalSince1970 * 1000)
        )
        reminders.insert(reminder, at: 0)
        persist()
        return reminder
    }

    func updateReminder(id: String, input: ReminderInput) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders[index].title = input.title.trimmingCharacters(in: .whitespacesAndNewlines)
        reminders[index].emoji = input.emoji
        reminders[index].categoryId = input.categoryId
        reminders[index].time = input.time
        reminders[index].scheduleType = input.scheduleType
        reminders[index].startDate = input.startDate
        reminders[index].weekdays = input.scheduleType == .selectedDays ? (input.weekdays ?? []) : nil
        reminders[index].enabled = input.enabled
        persist()
    }

    func setEnabled(id: String, enabled: Bool) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders[index].enabled = enabled
        persist()
    }

    func setNotificationIds(id: String, notificationIds: [String]) {
        guard let index = reminders.firstIndex(where: { $0.id == id }) else { return }
        reminders[index].notificationIds = notificationIds
        persist()
    }

    @discardableResult
    func removeReminder(id: String) -> [String] {
        let ids = reminders.first(where: { $0.id == id })?.notificationIds ?? []
        reminders.removeAll { $0.id == id }
        persist()
        return ids
    }

    private func persist() {
        do {
            let data = try encoder.encode(Payload(reminders: reminders))
            userDefaults.set(data, forKey: Storage.key)
        } catch {
            userDefaults.removeObject(forKey: Storage.key)
        }
    }

    private static func load(from userDefaults: UserDefaults, decoder: JSONDecoder) -> [Reminder]? {
        guard let data = userDefaults.data(forKey: Storage.key) else { return nil }
        do {
            return try decoder.decode(Payload.self, from: data).reminders
        } catch {
            userDefaults.removeObject(forKey: Storage.key)
            return nil
        }
    }

    static func generateID() -> String {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let random = Int.random(in: 0..<1_000_000)
        return "\(timestamp)-\(random)"
    }

    private enum Storage {
        static let key = "spark-reminders-recurring"
    }
}
