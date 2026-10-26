//
//  MoodEntry.swift
//  Spark
//
//  Purpose:
//  Feelings check-in mood entry model.
//
//  Responsibilities:
//  • Stores mood selections and timestamps for the feelings tracker.
//

import Foundation

struct MoodEntry: Codable, Equatable, Identifiable {
    let id: String
    var mood: String
    var emoji: String
    var intensity: Int
    var note: String?
    let createdAt: Int64
}
