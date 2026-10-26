//
//  DatesStore.swift
//  Spark
//
//  Purpose:
//  Important dates collection and persistence.
//
//  Responsibilities:
//  • Adds, updates, and removes scheduled events.
//

import Foundation
import Observation

@Observable
final class DatesStore {
    private struct Payload: Codable {
        var dates: [ImportantDate]
    }

    private(set) var dates: [ImportantDate] = []

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        dates = Self.load(from: userDefaults, decoder: decoder) ?? []
    }

    func addDate(_ date: ImportantDate) {
        dates.insert(date, at: 0)
        dates.sort { $0.createdAt > $1.createdAt }
        persist()
    }

    func updateDate(_ date: ImportantDate) {
        guard let index = dates.firstIndex(where: { $0.id == date.id }) else { return }
        dates[index] = date
        persist()
    }

    func updateDate(id: String, notificationId: String?) {
        guard let index = dates.firstIndex(where: { $0.id == id }) else { return }
        dates[index].notificationId = notificationId
        persist()
    }

    func removeDate(id: String) {
        dates.removeAll { $0.id == id }
        persist()
    }

    var sortedByNextOccurrence: [ImportantDate] {
        dates.sorted {
            UpcomingAggregator.nextOccurrence(date: $0.date, recurring: $0.recurring)
                < UpcomingAggregator.nextOccurrence(date: $1.date, recurring: $1.recurring)
        }
    }

    private func persist() {
        do {
            let data = try encoder.encode(Payload(dates: dates))
            userDefaults.set(data, forKey: Storage.key)
        } catch {
            userDefaults.removeObject(forKey: Storage.key)
        }
    }

    private static func load(from userDefaults: UserDefaults, decoder: JSONDecoder) -> [ImportantDate]? {
        guard let data = userDefaults.data(forKey: Storage.key) else { return nil }
        do {
            return try decoder.decode(Payload.self, from: data).dates
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
        static let key = "spark-dates"
    }
}
