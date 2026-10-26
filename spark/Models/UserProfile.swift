//
//  UserProfile.swift
//  Spark
//
//  Purpose:
//  Local user profile model and storage key constants.
//
//  Responsibilities:
//  • Represents onboarding-created profile fields and persistence key.
//

import Foundation

/// Local user profile created during onboarding and edited on the Me tab.
struct UserProfile: Codable, Equatable {
    let id: String
    var displayName: String
    var avatarName: String
    var bio: String?
    var likes: String?
    var dislikes: String?
    let createdAt: Int64
}

enum ProfileStorage {
    /// UserDefaults key for persisted profile JSON.
    static let key = "spark-profile"
}
