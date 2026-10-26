//
//  FocusStore.swift
//  Spark
//
//  Purpose:
//  Focus session stats and running-state indicators.
//
//  Responsibilities:
//  • Tracks focus minutes, sparks, and ephemeral running state.
//  • Records completed focus sessions from the timer engine.
//

import Foundation
import Observation

@Observable
final class FocusStore {
    private struct Payload: Codable {
        var sessionsCompleted: Int
        var totalMinutes: Int
        var sparksEarned: Int
        var sessions: [FocusSession]
    }

    private(set) var sessionsCompleted = 0
    private(set) var totalMinutes = 0
    private(set) var sparksEarned = 0
    private(set) var sessions: [FocusSession] = []

    /// Ephemeral — not persisted. Drives the Focus tab running indicator.
    private(set) var activeRealmName: String?

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let payload = Self.load(from: userDefaults, decoder: decoder) {
            sessionsCompleted = payload.sessionsCompleted
            totalMinutes = payload.totalMinutes
            sparksEarned = payload.sparksEarned
            sessions = payload.sessions
        }
    }

    static func sparksForMinutes(_ minutes: Int) -> Int {
        minutes < 1 ? 0 : max(1, minutes / 5)
    }

    func setActiveRealm(name: String?) {
        activeRealmName = name
    }

    func addSession(minutes: Int, realmID: String?, realmName: String?) {
        let whole = max(0, minutes)
        let entry = FocusSession(
            id: Self.generateID(),
            minutes: whole,
            realmId: realmID,
            realmName: realmName,
            completedAt: Int64(Date().timeIntervalSince1970 * 1000)
        )
        sessionsCompleted += 1
        totalMinutes += whole
        sparksEarned += max(1, Self.sparksForMinutes(whole))
        sessions.insert(entry, at: 0)
        persist()
    }

    private func persist() {
        do {
            let payload = Payload(
                sessionsCompleted: sessionsCompleted,
                totalMinutes: totalMinutes,
                sparksEarned: sparksEarned,
                sessions: sessions
            )
            let data = try encoder.encode(payload)
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
        static let key = "spark-focus"
    }
}
