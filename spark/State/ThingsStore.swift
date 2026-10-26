//
//  ThingsStore.swift
//  Spark
//
//  Purpose:
//  Find My Things item persistence.
//
//  Responsibilities:
//  • Stores searchable items and category assignments.
//

import Foundation
import Observation

@Observable
final class ThingsStore {
    private struct Payload: Codable {
        var items: [StoredItem]
    }

    private(set) var items: [StoredItem] = []

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        items = Self.load(from: userDefaults, decoder: decoder) ?? []
    }

    func addItem(_ input: ThingComposerInput) {
        let item = StoredItem(
            id: Self.generateID(),
            name: input.name.trimmingCharacters(in: .whitespacesAndNewlines),
            location: input.location.trimmingCharacters(in: .whitespacesAndNewlines),
            category: input.category,
            note: input.note?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
                ? input.note?.trimmingCharacters(in: .whitespacesAndNewlines)
                : nil,
            emoji: input.emoji,
            updatedAt: Int64(Date().timeIntervalSince1970 * 1000)
        )
        items.insert(item, at: 0)
        persist()
    }

    func updateItem(id: String, input: ThingComposerInput) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].name = input.name.trimmingCharacters(in: .whitespacesAndNewlines)
        items[index].location = input.location.trimmingCharacters(in: .whitespacesAndNewlines)
        items[index].category = input.category
        items[index].emoji = input.emoji
        let trimmedNote = input.note?.trimmingCharacters(in: .whitespacesAndNewlines)
        items[index].note = trimmedNote?.isEmpty == false ? trimmedNote : nil
        items[index].updatedAt = Int64(Date().timeIntervalSince1970 * 1000)
        persist()
    }

    func updateLocation(id: String, location: String) {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return }
        items[index].location = location.trimmingCharacters(in: .whitespacesAndNewlines)
        items[index].updatedAt = Int64(Date().timeIntervalSince1970 * 1000)
        persist()
    }

    func removeItem(id: String) {
        items.removeAll { $0.id == id }
        persist()
    }

    private func persist() {
        do {
            let data = try encoder.encode(Payload(items: items))
            userDefaults.set(data, forKey: Storage.key)
        } catch {
            userDefaults.removeObject(forKey: Storage.key)
        }
    }

    private static func load(from userDefaults: UserDefaults, decoder: JSONDecoder) -> [StoredItem]? {
        guard let data = userDefaults.data(forKey: Storage.key) else { return nil }
        do {
            return try decoder.decode(Payload.self, from: data).items
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
        static let key = "spark-things"
    }
}
