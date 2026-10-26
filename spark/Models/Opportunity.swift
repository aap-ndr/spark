//
//  Opportunity.swift
//  Spark
//
//  Purpose:
//  Discover Opportunities item model and link helpers.
//
//  Responsibilities:
//  • Defines opportunity metadata and external URL resolution.
//

import SwiftUI

enum OpportunityCategory: String, Codable, CaseIterable, Hashable, Identifiable {
    case volunteer = "Volunteer"
    case camps = "Camps"
    case competitions = "Competitions"
    case leadership = "Leadership"
    case tech = "Tech"
    case arts = "Arts"

    var id: String { rawValue }
}

enum OpportunityCost: String, Codable, Hashable {
    case free = "Free"
    case paid = "Paid"
    case scholarship = "Scholarship"
}

struct Opportunity: Identifiable, Equatable, Hashable, Codable {
    let id: String
    let title: String
    let org: String
    let category: OpportunityCategory
    let description: String
    let deadline: String
    let location: String
    let cost: OpportunityCost
    let link: String?
    let imageColorHex: UInt

    var imageColor: Color {
        Color(sparkHex: imageColorHex)
    }

    /// External link for the opportunity, falling back to a Google search when none is provided.
    var externalURLString: String {
        if let link, !link.isEmpty {
            return link
        }
        let query = "\(title) \(org)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? title
        return "https://www.google.com/search?q=\(query)"
    }
}

enum OpportunityFilter: Hashable, Identifiable {
    case all
    case saved
    case category(OpportunityCategory)

    var id: String {
        switch self {
        case .all: return "All"
        case .saved: return "Saved"
        case .category(let category): return category.rawValue
        }
    }

    var label: String { id }

    static var filterOrder: [OpportunityFilter] {
        [.all, .saved] + OpportunityCategory.allCases.map { .category($0) }
    }
}

struct OpportunityCostStyle {
    let background: Color
    let foreground: Color

    static func style(for cost: OpportunityCost) -> OpportunityCostStyle {
        switch cost {
        case .free:
            return OpportunityCostStyle(
                background: SparkColors.mintSoft,
                foreground: Color(sparkHex: 0x2E9E8B)
            )
        case .scholarship:
            return OpportunityCostStyle(
                background: SparkColors.lavenderSoft,
                foreground: SparkColors.lavender
            )
        case .paid:
            return OpportunityCostStyle(
                background: SparkColors.peachSoft,
                foreground: Color(sparkHex: 0xE08A5A)
            )
        }
    }
}
