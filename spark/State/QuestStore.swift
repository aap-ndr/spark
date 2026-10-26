//
//  QuestStore.swift
//  Spark
//
//  Purpose:
//  Quest list persistence and mutation APIs.
//
//  Responsibilities:
//  • Creates, reorders, completes, and deletes quests.
//  • Manages quest steps, reminders, and circle sharing metadata.
//

import Foundation
import Observation

@Observable
final class QuestStore {
    private struct Payload: Codable {
        var quests: [Quest]
    }

    private struct LegacyQuest: Codable {
        var id: String
        var title: String
        var emoji: String
        var color: String
        var steps: [QuestStep]
        var createdAt: Int64
        var remindAt: Int64?
        var notificationId: String?
        var circleIds: [String]?
        var circleId: String?
    }

    private(set) var quests: [Quest] = []
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if let loaded = Self.load(from: userDefaults, decoder: decoder) {
            quests = loaded
        } else {
            quests = Self.seedQuests()
        }
        persist()
    }

    var questSparks: Int {
        quests.reduce(0) { partial, quest in
            partial + quest.steps.filter(\.done).count
        }
    }

    func addQuest(
        title: String,
        emoji: String,
        gradientKey: String,
        steps: [String],
        circleIds: [String]? = nil
    ) {
        let trimmedSteps = steps
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { makeStep(text: $0) }

        let quest = Quest(
            id: Self.generateID(),
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            emoji: emoji,
            color: gradientKey,
            steps: trimmedSteps,
            createdAt: Int64(Date().timeIntervalSince1970 * 1000),
            remindAt: nil,
            notificationId: nil,
            circleIds: circleIds?.isEmpty == false ? circleIds : nil
        )
        quests.insert(quest, at: 0)
        persist()
    }

    func toggleStep(questID: String, stepID: String) {
        quests = quests.map { quest in
            guard quest.id == questID else { return quest }
            var updated = quest
            updated.steps = quest.steps.map { step in
                guard step.id == stepID else { return step }
                var toggled = step
                toggled.done.toggle()
                return toggled
            }
            return updated
        }
        persist()
    }

    func toggleQuestCircle(questID: String, circleID: String) {
        quests = quests.map { quest in
            guard quest.id == questID else { return quest }
            var updated = quest
            var current = quest.circleIds ?? []
            if current.contains(circleID) {
                current.removeAll { $0 == circleID }
            } else {
                current.append(circleID)
            }
            updated.circleIds = current.isEmpty ? nil : current
            return updated
        }
        persist()
    }

    @discardableResult
    func deleteQuest(id: String) -> String? {
        let notificationID = quests.first(where: { $0.id == id })?.notificationId
        quests.removeAll { $0.id == id }
        persist()
        return notificationID
    }

    func setQuestReminder(questID: String, remindAt: Int64, notificationID: String) {
        quests = quests.map { quest in
            guard quest.id == questID else { return quest }
            var updated = quest
            updated.remindAt = remindAt
            updated.notificationId = notificationID
            return updated
        }
        persist()
    }

    func clearQuestReminder(questID: String) {
        quests = quests.map { quest in
            guard quest.id == questID else { return quest }
            var updated = quest
            updated.remindAt = nil
            updated.notificationId = nil
            return updated
        }
        persist()
    }

    func setQuestOrder(orderedIDs: [String]) {
        let byID = Dictionary(uniqueKeysWithValues: quests.map { ($0.id, $0) })
        var next: [Quest] = []
        for id in orderedIDs {
            if let quest = byID[id] {
                next.append(quest)
            }
        }
        for quest in quests where !orderedIDs.contains(quest.id) {
            next.append(quest)
        }
        quests = next
        persist()
    }

    func addStep(questID: String, text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        quests = quests.map { quest in
            guard quest.id == questID else { return quest }
            var updated = quest
            updated.steps.append(makeStep(text: trimmed))
            return updated
        }
        persist()
    }

    private func persist() {
        do {
            let data = try encoder.encode(Payload(quests: quests))
            userDefaults.set(data, forKey: Storage.key)
        } catch {
            quests = Self.seedQuests()
            userDefaults.removeObject(forKey: Storage.key)
        }
    }

    private static func load(from userDefaults: UserDefaults, decoder: JSONDecoder) -> [Quest]? {
        guard let data = userDefaults.data(forKey: Storage.key) else { return nil }
        do {
            let payload = try decoder.decode(Payload.self, from: data)
            return migrateLegacyCircles(payload.quests)
        } catch {
            if let migrated = migrateLegacyPayload(data: data, decoder: decoder) {
                return migrated
            }
            userDefaults.removeObject(forKey: Storage.key)
            return nil
        }
    }

    private static func migrateLegacyPayload(data: Data, decoder: JSONDecoder) -> [Quest]? {
        guard let legacy = try? decoder.decode([LegacyQuest].self, from: data) else {
            return nil
        }
        let migrated = legacy.map { item -> Quest in
            var circleIDs = item.circleIds
            if circleIDs == nil, let legacyCircleID = item.circleId {
                circleIDs = [legacyCircleID]
            }
            return Quest(
                id: item.id,
                title: item.title,
                emoji: item.emoji,
                color: item.color,
                steps: item.steps,
                createdAt: item.createdAt,
                remindAt: item.remindAt,
                notificationId: item.notificationId,
                circleIds: circleIDs
            )
        }
        return migrateLegacyCircles(migrated)
    }

    private static func migrateLegacyCircles(_ quests: [Quest]) -> [Quest] {
        quests
    }

    private static func makeStep(text: String) -> QuestStep {
        QuestStep(
            id: generateID(),
            text: text.trimmingCharacters(in: .whitespacesAndNewlines),
            done: false,
            remindAt: nil,
            notificationId: nil
        )
    }

    private func makeStep(text: String) -> QuestStep {
        Self.makeStep(text: text)
    }

    private static func seedQuests() -> [Quest] {
        let now = Int64(Date().timeIntervalSince1970 * 1000)
        return [
            Quest(
                id: generateID(),
                title: "Get ready for school",
                emoji: "☀️",
                color: "sunrise",
                steps: [
                    makeStep(text: "Drink a glass of water"),
                    makeStep(text: "Get dressed"),
                    makeStep(text: "Pack my bag"),
                ],
                createdAt: now,
                remindAt: nil,
                notificationId: nil,
                circleIds: nil
            ),
            Quest(
                id: generateID(),
                title: "Reset my desk",
                emoji: "🧺",
                color: "garden",
                steps: [
                    makeStep(text: "Clear the cups & wrappers"),
                    makeStep(text: "Stack my books"),
                ],
                createdAt: now - 1,
                remindAt: nil,
                notificationId: nil,
                circleIds: nil
            ),
        ]
    }

    private static func generateID() -> String {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let random = Int.random(in: 0..<1_000_000)
        return "\(timestamp)-\(random)"
    }

    private enum Storage {
        static let key = "spark-quests"
    }
}
