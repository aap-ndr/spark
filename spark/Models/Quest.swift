//
//  Quest.swift
//  Spark
//
//  Purpose:
//  Quest model with steps, reminders, and circle sharing.
//
//  Responsibilities:
//  • Represents quest progress, metadata, and completion state.
//

import Foundation

struct QuestStep: Codable, Equatable, Identifiable {
    let id: String
    var text: String
    var done: Bool
    var remindAt: Int64?
    var notificationId: String?
}

struct Quest: Codable, Equatable, Identifiable {
    let id: String
    var title: String
    var emoji: String
    var color: String
    var steps: [QuestStep]
    let createdAt: Int64
    var remindAt: Int64?
    var notificationId: String?
    var circleIds: [String]?
}
