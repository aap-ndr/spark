//
//  CycleStore.swift
//  Spark
//
//  Purpose:
//  Cycle tracking entries and averages.
//
//  Responsibilities:
//  • Logs period entries and computes cycle length statistics.
//

import Foundation
import Observation

@Observable
final class CycleStore {
    private struct Payload: Codable {
        var entries: [CycleEntry]
        var averageCycleLength: Int
    }

    private(set) var entries: [CycleEntry] = []
    private(set) var averageCycleLength = 28

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let payload = Self.load(from: userDefaults, decoder: decoder) {
            entries = payload.entries
            averageCycleLength = payload.averageCycleLength
        }
    }

    func logPeriod(startDate: Int64) {
        guard !entries.contains(where: { CycleHelpers.sameDay($0.startDate, startDate) }) else {
            return
        }

        let entry = CycleEntry(
            id: Self.generateID(),
            startDate: startDate,
            createdAt: Int64(Date().timeIntervalSince1970 * 1000)
        )
        entries.insert(entry, at: 0)
        entries.sort { $0.startDate > $1.startDate }
        persist()
    }

    func removeEntry(id: String) {
        entries.removeAll { $0.id == id }
        persist()
    }

    func setAverageCycleLength(_ length: Int) {
        averageCycleLength = length
        persist()
    }

    private func persist() {
        do {
            let data = try encoder.encode(Payload(entries: entries, averageCycleLength: averageCycleLength))
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

    private static func generateID() -> String {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let random = Int.random(in: 0..<1_000_000)
        return "\(timestamp)-\(random)"
    }

    private enum Storage {
        static let key = "spark-cycle"
    }
}
