//
//  ReminderCategoriesStore.swift
//  Spark
//
//  Purpose:
//  Reminder category definitions and persistence.
//
//  Responsibilities:
//  • Creates and manages user-defined reminder categories.
//

import Foundation
import Observation

@Observable
final class ReminderCategoriesStore {
    private struct Payload: Codable {
        var categories: [ReminderCategory]
    }

    private(set) var categories: [ReminderCategory] = ReminderCategoryDefaults.seeded

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let loaded = Self.load(from: userDefaults, decoder: decoder) {
            categories = Self.ensureOtherCategory(in: loaded)
        }
    }

    @discardableResult
    func addCategory(label: String, emoji: String, colorHex: UInt = 0x6B26D6) -> ReminderCategory {
        let category = ReminderCategory(
            id: Self.generateID(),
            label: label.trimmingCharacters(in: .whitespacesAndNewlines),
            emoji: emoji.isEmpty ? "✨" : emoji,
            colorHex: colorHex
        )
        if let otherIndex = categories.firstIndex(where: { $0.id == ReminderCategoryDefaults.otherCategoryID }) {
            categories.insert(category, at: otherIndex)
        } else {
            categories.append(category)
        }
        persist()
        return category
    }

    func removeCategory(id: String) {
        guard id != ReminderCategoryDefaults.otherCategoryID else { return }
        categories.removeAll { $0.id == id }
        persist()
    }

    func resetCategories() {
        categories = ReminderCategoryDefaults.seeded
        persist()
    }

    func category(for id: String?) -> ReminderCategory? {
        guard let id else { return nil }
        return categories.first { $0.id == id }
    }

    private func persist() {
        do {
            let data = try encoder.encode(Payload(categories: categories))
            userDefaults.set(data, forKey: Storage.key)
        } catch {
            userDefaults.removeObject(forKey: Storage.key)
        }
    }

    private static func load(from userDefaults: UserDefaults, decoder: JSONDecoder) -> [ReminderCategory]? {
        guard let data = userDefaults.data(forKey: Storage.key) else { return nil }
        do {
            return try decoder.decode(Payload.self, from: data).categories
        } catch {
            userDefaults.removeObject(forKey: Storage.key)
            return nil
        }
    }

    private static func ensureOtherCategory(in categories: [ReminderCategory]) -> [ReminderCategory] {
        if categories.contains(where: { $0.id == ReminderCategoryDefaults.otherCategoryID }) {
            return categories
        }
        return categories + [ReminderCategoryDefaults.seeded.last!]
    }

    static func generateID() -> String {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let random = Int.random(in: 0..<1_000_000)
        return "cat-\(timestamp)-\(random)"
    }

    private enum Storage {
        static let key = "spark-reminder-categories"
    }
}
