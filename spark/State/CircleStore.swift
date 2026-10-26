//
//  CircleStore.swift
//  Spark
//
//  Purpose:
//  Local Spark Circle state and demo seed data.
//
//  Responsibilities:
//  • Manages circles, members, sparks, and body doubles.
//  • Persists circle data locally without networking.
//

import Foundation
import Observation

/// Local-only Spark Circle state. No networking, sync, or server validation.
@Observable
final class CircleStore {
    private struct Payload: Codable {
        var circles: [SparkCircle]
        var messages: [SparkMessage]
        var bodyDoubles: [BodyDoublePost]
        var blocked: [String]
    }

    private struct LegacyPayload: Codable {
        var circles: [SparkCircle]
    }

    private(set) var circles: [SparkCircle] = []
    private(set) var messages: [SparkMessage] = []
    private(set) var bodyDoubles: [BodyDoublePost] = []
    private(set) var blocked: [String] = []

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private static var idCounter = 0

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        load(from: userDefaults)
    }

    func circle(id: String) -> SparkCircle? {
        circles.first { $0.id == id }
    }

    func messages(for circleID: String) -> [SparkMessage] {
        messages.filter { $0.circleId == circleID }
    }

    func bodyDoubles(for circleID: String) -> [BodyDoublePost] {
        bodyDoubles
            .filter { $0.circleId == circleID }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func isBlocked(_ memberID: String) -> Bool {
        blocked.contains(memberID)
    }

    @discardableResult
    func createCircle(name: String, emoji: String, me: SparkCircleMember) -> SparkCircle {
        let circle = SparkCircle(
            id: Self.generateID(),
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            emoji: emoji,
            inviteCode: Self.generateInviteCode(),
            members: [me] + CircleContent.seedFriends,
            createdAt: Self.now
        )
        circles.insert(circle, at: 0)
        bodyDoubles = Self.seedBodyDoubles(circleID: circle.id) + bodyDoubles
        persist()
        return circle
    }

    @discardableResult
    func joinCircle(code: String, me: SparkCircleMember) -> SparkCircle? {
        let trimmed = code.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 4 else { return nil }

        let circle = SparkCircle(
            id: Self.generateID(),
            name: CircleContent.joinDemoCircleName,
            emoji: CircleContent.joinDemoCircleEmoji,
            inviteCode: trimmed.uppercased(),
            members: [me] + CircleContent.seedFriends,
            createdAt: Self.now
        )
        circles.insert(circle, at: 0)
        bodyDoubles = Self.seedBodyDoubles(circleID: circle.id) + bodyDoubles
        persist()
        return circle
    }

    func sendSpark(circleID: String, text: String, me: SparkCircleMember) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        if let last = messages.last,
           last.circleId == circleID,
           last.direction == .outgoing,
           last.text == trimmed,
           Self.now - last.createdAt < 800 {
            return
        }

        let message = SparkMessage(
            id: Self.generateID(),
            circleId: circleID,
            fromName: me.displayName,
            fromAvatar: me.avatarName,
            text: trimmed,
            createdAt: Self.now,
            direction: .outgoing
        )
        messages.append(message)
        persist()
    }

    func receiveDemoSpark(circleID: String, text: String) {
        let circle = circles.first { $0.id == circleID }
        let friend = circle?.members.dropFirst().first ?? CircleContent.seedFriends[0]
        let message = SparkMessage(
            id: Self.generateID(),
            circleId: circleID,
            fromName: friend.displayName,
            fromAvatar: friend.avatarName,
            text: text,
            createdAt: Self.now,
            direction: .incoming
        )
        messages.append(message)
        persist()
    }

    func postBodyDouble(
        circleID: String,
        kind: BodyDoubleKind,
        task: String?,
        when: String?,
        note: String?,
        me: SparkCircleMember
    ) {
        let post = BodyDoublePost(
            id: Self.generateID(),
            circleId: circleID,
            kind: kind,
            fromName: me.displayName,
            fromAvatar: me.avatarName,
            task: task?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            when: when?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            note: note?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfEmpty,
            createdAt: Self.now,
            mine: true
        )
        bodyDoubles.append(post)
        persist()
    }

    func removeBodyDouble(id: String) {
        bodyDoubles.removeAll { $0.id == id }
        persist()
    }

    func blockMember(_ memberID: String) {
        guard !blocked.contains(memberID) else { return }
        blocked.append(memberID)
        persist()
    }

    // MARK: - Persistence

    private func load(from userDefaults: UserDefaults) {
        guard let data = userDefaults.data(forKey: Storage.key) else { return }

        if let payload = try? decoder.decode(Payload.self, from: data) {
            circles = payload.circles
            messages = payload.messages
            bodyDoubles = payload.bodyDoubles
            blocked = payload.blocked
            return
        }

        if let legacy = try? decoder.decode(LegacyPayload.self, from: data) {
            circles = legacy.circles
            messages = []
            bodyDoubles = []
            blocked = []
            persist()
            return
        }

        userDefaults.removeObject(forKey: Storage.key)
    }

    private func persist() {
        do {
            let payload = Payload(
                circles: circles,
                messages: messages,
                bodyDoubles: bodyDoubles,
                blocked: blocked
            )
            let data = try encoder.encode(payload)
            userDefaults.set(data, forKey: Storage.key)
        } catch {
            userDefaults.removeObject(forKey: Storage.key)
        }
    }

    // MARK: - ID helpers

    private static var now: Int64 {
        Int64(Date().timeIntervalSince1970 * 1000)
    }

    private static func generateID() -> String {
        idCounter += 1
        let random = Int.random(in: 0..<1_000_000)
        return "\(now)-\(idCounter)-\(random)"
    }

    private static func generateInviteCode() -> String {
        let charset = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<6).map { _ in charset.randomElement()! })
    }

    private static func seedBodyDoubles(circleID: String) -> [BodyDoublePost] {
        let maya = CircleContent.seedFriends[0]
        let priya = CircleContent.seedFriends[1]
        let nowMs = now
        return [
            BodyDoublePost(
                id: "\(generateID())-bd1",
                circleId: circleID,
                kind: .free,
                fromName: maya.displayName,
                fromAvatar: maya.avatarName,
                task: nil,
                when: "7–8pm tonight",
                note: "Free to focus together — I have some reading to get through 📚",
                createdAt: nowMs - 1_800_000,
                mine: false
            ),
            BodyDoublePost(
                id: "\(generateID())-bd2",
                circleId: circleID,
                kind: .need,
                fromName: priya.displayName,
                fromAvatar: priya.avatarName,
                task: "Math homework",
                when: "Right now",
                note: "Would love company to stay on track 💗",
                createdAt: nowMs - 600_000,
                mine: false
            ),
        ]
    }

    private enum Storage {
        static let key = "spark-circles"
    }
}

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
