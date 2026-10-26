//
//  StoredItem.swift
//  Spark
//
//  Purpose:
//  Find My Things stored item model.
//
//  Responsibilities:
//  • Captures item name, category, and location notes.
//

import Foundation

enum ThingCategory: String, Codable, CaseIterable {
    case electronics
    case bags
    case keys
    case accessories
    case wallet
    case other
}

struct StoredItem: Codable, Equatable, Identifiable {
    let id: String
    var name: String
    var location: String
    var category: ThingCategory?
    var note: String?
    var emoji: String?
    var updatedAt: Int64
}

struct ThingComposerInput {
    let name: String
    let location: String
    let note: String?
    let emoji: String?
    let category: ThingCategory
}
