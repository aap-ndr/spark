//
//  TimerStore.swift
//  Spark
//
//  Purpose:
//  Standalone toolkit timer preferences.
//
//  Responsibilities:
//  • Persists timer presets separate from Focus Realms.
//

import Foundation
import Observation

/// Standalone toolkit timer state — separate from Focus Realms.
@Observable
final class TimerStore {
    private struct Payload: Codable {
        var soundId: String
        var lastDurationSec: Int
    }

    var durationSec = 25 * 60
    var endsAt: Int64?
    var running = false
    var remainingSec = 25 * 60

    var soundId = TimerSounds.defaultSoundID
    var lastDurationSec = 25 * 60

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let payload = Self.load(from: userDefaults, decoder: decoder) {
            soundId = payload.soundId
            lastDurationSec = payload.lastDurationSec
            durationSec = payload.lastDurationSec
            remainingSec = payload.lastDurationSec
        }
    }

    func start(durationSec: Int) {
        let clamped = max(1, durationSec)
        self.durationSec = clamped
        remainingSec = clamped
        lastDurationSec = clamped
        endsAt = Int64(Date().timeIntervalSince1970 * 1000) + Int64(clamped) * 1000
        running = true
        persist()
    }

    func pause() {
        if let endsAt {
            remainingSec = max(0, Int(round(Double(endsAt - nowMs()) / 1000)))
        }
        running = false
        self.endsAt = nil
    }

    func resume() {
        guard remainingSec > 0 else { return }
        running = true
        endsAt = Int64(Date().timeIntervalSince1970 * 1000) + Int64(remainingSec) * 1000
    }

    func reset() {
        running = false
        endsAt = nil
        remainingSec = durationSec
    }

    func setDurationWhileIdle(seconds: Int) {
        guard !running else { return }
        let clamped = max(1, seconds)
        durationSec = clamped
        remainingSec = clamped
    }

    func setSound(_ id: String) {
        soundId = id
        persist()
    }

    func remainingSeconds(at now: Date = Date()) -> Int {
        if running, let endsAt {
            return max(0, Int(round(Double(endsAt - Int64(now.timeIntervalSince1970 * 1000)) / 1000)))
        }
        return remainingSec
    }

    private func persist() {
        do {
            let data = try encoder.encode(
                Payload(soundId: soundId, lastDurationSec: lastDurationSec)
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

    private func nowMs() -> Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }

    private enum Storage {
        static let key = "spark-timer"
    }
}
