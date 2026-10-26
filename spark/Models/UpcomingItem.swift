//
//  UpcomingItem.swift
//  Spark
//
//  Purpose:
//  Unified upcoming item shown on the home screen.
//
//  Responsibilities:
//  • Represents aggregated reminders, dates, quests, and cycle events.
//

import Foundation

enum UpcomingSource: String, Codable {
    case event
    case cycle
    case quest
    case reminder
}

struct UpcomingItem: Identifiable, Equatable {
    let id: String
    let source: UpcomingSource
    let emoji: String
    let title: String
    let when: Int64
    let route: AppRoute
}
