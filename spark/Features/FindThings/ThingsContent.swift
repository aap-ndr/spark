//
//  ThingsContent.swift
//  Spark
//
//  Purpose:
//  Find My Things categories and static copy.
//
//  Responsibilities:
//  • Defines default categories and search helpers.
//

import Foundation
import SwiftUI

struct ThingCategoryMeta: Identifiable {
    let id: ThingCategory
    let label: String
    let emoji: String
}

struct ThingQuickPick: Identifiable {
    let name: String
    let emoji: String
    let category: ThingCategory
    var id: String { name }
}

enum ThingsContent {
    static let categories: [ThingCategoryMeta] = [
        ThingCategoryMeta(id: .electronics, label: "Electronics", emoji: "📱"),
        ThingCategoryMeta(id: .bags, label: "Bags & Purses", emoji: "👜"),
        ThingCategoryMeta(id: .keys, label: "Keys", emoji: "🔑"),
        ThingCategoryMeta(id: .accessories, label: "Accessories", emoji: "👓"),
        ThingCategoryMeta(id: .wallet, label: "Wallet & Cards", emoji: "💳"),
        ThingCategoryMeta(id: .other, label: "Other", emoji: "✨"),
    ]

    static let quickItems: [ThingQuickPick] = [
        ThingQuickPick(name: "Phone", emoji: "📱", category: .electronics),
        ThingQuickPick(name: "Glasses", emoji: "👓", category: .accessories),
        ThingQuickPick(name: "Purse", emoji: "👜", category: .bags),
        ThingQuickPick(name: "Keys", emoji: "🔑", category: .keys),
        ThingQuickPick(name: "Wallet", emoji: "👛", category: .wallet),
        ThingQuickPick(name: "Charger", emoji: "🔌", category: .electronics),
        ThingQuickPick(name: "Headphones", emoji: "🎧", category: .electronics),
    ]

    static func category(of item: StoredItem) -> ThingCategory {
        item.category ?? .other
    }

    static func meta(for category: ThingCategory) -> ThingCategoryMeta {
        categories.first { $0.id == category } ?? categories.last!
    }

    static func timeAgo(_ milliseconds: Int64) -> String {
        let diff = Date().timeIntervalSince1970 * 1000 - Double(milliseconds)
        let mins = Int(diff / 60_000)

        if mins < 1 { return "just now" }
        if mins < 60 { return "\(mins) min\(mins == 1 ? "" : "s") ago" }

        let hrs = mins / 60
        if hrs < 24 { return "\(hrs) hour\(hrs == 1 ? "" : "s") ago" }

        let days = hrs / 24
        if days == 1 { return "yesterday" }
        if days < 7 { return "\(days) days ago" }

        let weeks = days / 7
        if weeks < 5 { return "\(weeks) week\(weeks == 1 ? "" : "s") ago" }

        let date = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
        return date.formatted(date: .abbreviated, time: .omitted)
    }

    static func visibleItems(
        from items: [StoredItem],
        search: String,
        filter: ThingFilter
    ) -> [StoredItem] {
        let query = search.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return items.filter { item in
            let matchesCategory = filter == .all || category(of: item) == filter.category
            guard matchesCategory else { return false }
            guard !query.isEmpty else { return true }
            return item.name.lowercased().contains(query)
                || item.location.lowercased().contains(query)
        }
    }

    static func categoryCounts(for items: [StoredItem]) -> [ThingCategory: Int] {
        var map: [ThingCategory: Int] = [:]
        for item in items {
            let category = category(of: item)
            map[category, default: 0] += 1
        }
        return map
    }
}

enum ThingFilter: Equatable {
    case all
    case category(ThingCategory)

    var category: ThingCategory? {
        switch self {
        case .all: return nil
        case .category(let category): return category
        }
    }
}
