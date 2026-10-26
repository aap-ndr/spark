//
//  SavedOpportunitiesStore.swift
//  Spark
//
//  Purpose:
//  Saved opportunity bookmark IDs.
//
//  Responsibilities:
//  • Persists and toggles saved Discover Opportunities items.
//

import Foundation
import Observation

/// Persists bookmarked opportunity IDs in UserDefaults.
@Observable
final class SavedOpportunitiesStore {
    private(set) var saved: [String] = []

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        saved = Self.load(from: userDefaults, decoder: decoder)
    }

    func isSaved(_ id: String) -> Bool {
        saved.contains(id)
    }

    func toggle(_ id: String) {
        if saved.contains(id) {
            saved.removeAll { $0 == id }
        } else {
            saved.append(id)
        }
        persist()
    }

    private func persist() {
        let payload = ZustandPersisted(state: SavedPayload(saved: saved), version: 0)
        do {
            let data = try encoder.encode(payload)
            userDefaults.set(data, forKey: Storage.key)
        } catch {
            saved = []
            userDefaults.removeObject(forKey: Storage.key)
        }
    }

    private static func load(from userDefaults: UserDefaults, decoder: JSONDecoder) -> [String] {
        guard let data = userDefaults.data(forKey: Storage.key) else {
            return []
        }

        if let wrapped = try? decoder.decode(ZustandPersisted.self, from: data) {
            return wrapped.state.saved
        }

        if let payload = try? decoder.decode(SavedPayload.self, from: data) {
            return payload.saved
        }

        if let ids = try? decoder.decode([String].self, from: data) {
            return ids
        }

        userDefaults.removeObject(forKey: Storage.key)
        return []
    }

    private struct SavedPayload: Codable {
        var saved: [String]
    }

    /// Wrapped envelope retained for backward-compatible decoding.
    private struct ZustandPersisted: Codable {
        var state: SavedPayload
        var version: Int
    }

    private enum Storage {
        static let key = "spark-saved"
    }
}
