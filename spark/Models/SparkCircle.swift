//
//  SparkCircle.swift
//  Spark
//
//  Purpose:
//  Spark Circle group and member models.
//
//  Responsibilities:
//  • Represents circle membership, sparks, and shared activity.
//

import Foundation

struct SparkCircleMember: Codable, Equatable, Identifiable {
    let id: String
    var displayName: String
    var avatarName: String
}

struct SparkCircle: Codable, Equatable, Identifiable {
    let id: String
    var name: String
    var emoji: String
    var inviteCode: String
    var members: [SparkCircleMember]
    let createdAt: Int64
}

enum SparkMessageDirection: String, Codable {
    case incoming
    case outgoing
}

struct SparkMessage: Codable, Equatable, Identifiable {
    let id: String
    let circleId: String
    var fromName: String
    var fromAvatar: String
    var text: String
    let createdAt: Int64
    var direction: SparkMessageDirection
}

enum BodyDoubleKind: String, Codable {
    case need
    case free
}

struct BodyDoublePost: Codable, Equatable, Identifiable {
    let id: String
    let circleId: String
    var kind: BodyDoubleKind
    var fromName: String
    var fromAvatar: String
    var task: String?
    var when: String?
    var note: String?
    let createdAt: Int64
    var mine: Bool
}
