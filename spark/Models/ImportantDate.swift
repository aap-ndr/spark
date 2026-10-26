//
//  ImportantDate.swift
//  Spark
//
//  Purpose:
//  Important date/event model for the dates feature.
//
//  Responsibilities:
//  • Captures event details, reminders, and visual styling.
//

import Foundation

enum DateCategory: String, Codable, CaseIterable {
    case birthday
    case anniversary
    case party
    case exam
    case presentation
    case prom
    case sleepover
    case school
    case custom
}

enum DateRecurrence: String, Codable {
    case yearly
    case once
}

struct EventTime: Codable, Equatable {
    let hour: Int
    let minute: Int
}

struct ImportantDate: Codable, Equatable, Identifiable {
    let id: String
    var title: String
    var date: Int64
    var time: EventTime?
    var category: DateCategory
    var customCategory: String?
    var recurring: DateRecurrence
    var reminderEnabled: Bool?
    var reminderDaysBefore: Int
    var notificationId: String?
    var notes: String?
    let createdAt: Int64
}

struct CycleEntry: Codable, Equatable, Identifiable {
    let id: String
    let startDate: Int64
    let createdAt: Int64
}

struct FocusSession: Codable, Equatable, Identifiable {
    let id: String
    let minutes: Int
    var realmId: String?
    var realmName: String?
    let completedAt: Int64
}
