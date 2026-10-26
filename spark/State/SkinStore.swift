//
//  SkinStore.swift
//  Spark
//
//  Purpose:
//  Selected app skin persistence.
//
//  Responsibilities:
//  • Loads and saves the active skin identifier locally.
//

import Foundation
import Observation

/// Persists the selected app skin via UserDefaults (`spark-skin`).
@Observable
final class SkinStore {
    private struct Payload: Codable {
        var skinId: String
    }

    private(set) var skinId: String

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    var activeSkin: SparkSkin {
        SparkSkinCatalog.skin(id: skinId)
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        skinId = Self.load(from: userDefaults, decoder: decoder) ?? SparkSkinCatalog.defaultSkin.id
    }

    func setSkin(_ id: String) {
        guard SparkSkinCatalog.all.contains(where: { $0.id == id }) else { return }
        skinId = id
        persist()
    }

    private func persist() {
        do {
            let data = try encoder.encode(Payload(skinId: skinId))
            userDefaults.set(data, forKey: Storage.key)
        } catch {
            userDefaults.removeObject(forKey: Storage.key)
        }
    }

    private static func load(from userDefaults: UserDefaults, decoder: JSONDecoder) -> String? {
        guard let data = userDefaults.data(forKey: Storage.key) else { return nil }
        if let payload = try? decoder.decode(Payload.self, from: data) {
            return payload.skinId
        }
        if let legacy = try? decoder.decode(LegacyZustand.self, from: data) {
            return legacy.state.skinId
        }
        return nil
    }

    /// Wrapped envelope for decoding older persisted skin payloads.
    private struct LegacyZustand: Codable {
        var state: Payload
        var version: Int?
    }

    private enum Storage {
        static let key = "spark-skin"
    }
}
