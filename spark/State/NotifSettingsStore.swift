//
//  NotifSettingsStore.swift
//  Spark
//
//  Purpose:
//  Notification preference settings.
//
//  Responsibilities:
//  • Persists user notification toggles and preferences.
//

import Foundation
import Observation

struct NotificationSettingsSnapshot: Equatable {
    var enabled: Bool
    var reminderHour: Int
    var reminderMinute: Int
    var perCategory: [DateCategory: Bool]

    static var defaults: NotificationSettingsSnapshot {
        NotificationSettingsSnapshot(
            enabled: false,
            reminderHour: 9,
            reminderMinute: 0,
            perCategory: Dictionary(uniqueKeysWithValues: DateCategory.allCases.map { ($0, true) })
        )
    }
}

@Observable
final class NotifSettingsStore {
    private struct Payload: Codable {
        var enabled: Bool
        var reminderHour: Int
        var reminderMinute: Int
        var perCategory: [String: Bool]
    }

    var enabled = false
    var reminderHour = 9
    var reminderMinute = 0
    var perCategory: [DateCategory: Bool] = Dictionary(uniqueKeysWithValues: DateCategory.allCases.map { ($0, true) })

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let payload = Self.load(from: userDefaults, decoder: decoder) {
            enabled = payload.enabled
            reminderHour = payload.reminderHour
            reminderMinute = payload.reminderMinute
            for category in DateCategory.allCases {
                if let value = payload.perCategory[category.rawValue] {
                    perCategory[category] = value
                }
            }
        }
    }

    var snapshot: NotificationSettingsSnapshot {
        NotificationSettingsSnapshot(
            enabled: enabled,
            reminderHour: reminderHour,
            reminderMinute: reminderMinute,
            perCategory: perCategory
        )
    }

    func setEnabled(_ value: Bool) {
        enabled = value
        persist()
    }

    func setTime(hour: Int, minute: Int) {
        reminderHour = hour
        reminderMinute = minute
        persist()
    }

    func toggleCategory(_ category: DateCategory) {
        perCategory[category] = !(perCategory[category] ?? true)
        persist()
    }

    private func persist() {
        let encodedCategories = Dictionary(uniqueKeysWithValues: perCategory.map { ($0.key.rawValue, $0.value) })
        do {
            let data = try encoder.encode(
                Payload(
                    enabled: enabled,
                    reminderHour: reminderHour,
                    reminderMinute: reminderMinute,
                    perCategory: encodedCategories
                )
            )
            userDefaults.set(data, forKey: Storage.key)
        } catch {
            userDefaults.removeObject(forKey: Storage.key)
        }
    }

    private static func load(from userDefaults: UserDefaults, decoder: JSONDecoder) -> Payload? {
        guard let data = userDefaults.data(forKey: Storage.key) else { return nil }
        do {
            return try decoder.decode(Payload.self, from: data)
        } catch {
            userDefaults.removeObject(forKey: Storage.key)
            return nil
        }
    }

    private enum Storage {
        static let key = "spark-notif-settings"
    }
}
