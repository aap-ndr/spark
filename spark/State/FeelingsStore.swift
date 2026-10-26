//
//  FeelingsStore.swift
//  Spark
//
//  Purpose:
//  Mood entries and feelings tracker persistence.
//
//  Responsibilities:
//  • Stores check-ins and supports feelings history views.
//

import Foundation
import Observation

@Observable
final class FeelingsStore {
    private struct Payload: Codable {
        var entries: [MoodEntry]
    }

    private(set) var entries: [MoodEntry] = []
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        entries = Self.load(from: userDefaults, decoder: decoder) ?? []
    }

    func addEntry(mood: String, emoji: String, intensity: Int, note: String?) {
        let trimmedNote = note?.trimmingCharacters(in: .whitespacesAndNewlines)
        let entry = MoodEntry(
            id: Self.generateID(),
            mood: mood,
            emoji: emoji,
            intensity: intensity,
            note: trimmedNote?.isEmpty == false ? trimmedNote : nil,
            createdAt: Int64(Date().timeIntervalSince1970 * 1000)
        )
        entries.insert(entry, at: 0)
        persist()
    }

    private func persist() {
        do {
            let data = try encoder.encode(Payload(entries: entries))
            userDefaults.set(data, forKey: Storage.key)
        } catch {
            userDefaults.removeObject(forKey: Storage.key)
        }
    }

    private static func load(from userDefaults: UserDefaults, decoder: JSONDecoder) -> [MoodEntry]? {
        guard let data = userDefaults.data(forKey: Storage.key) else { return nil }
        do {
            return try decoder.decode(Payload.self, from: data).entries
        } catch {
            userDefaults.removeObject(forKey: Storage.key)
            return nil
        }
    }

    private static func generateID() -> String {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let random = Int.random(in: 0..<1_000_000)
        return "\(timestamp)-\(random)"
    }

    private enum Storage {
        static let key = "spark-feelings"
    }
}
