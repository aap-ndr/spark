//
//  AppProfileStore.swift
//  Spark
//
//  Purpose:
//  Observable store for the local user profile.
//
//  Responsibilities:
//  • Creates, updates, and clears the persisted profile.
//  • Handles avatar normalization and older persisted profile formats.
//

import Foundation
import Observation

/// Persists the user's profile using Codable JSON in UserDefaults.
private struct ProfileStoragePayload: Codable {
    var profile: UserProfile?
}

@Observable
final class AppProfileStore {
    private(set) var profile: UserProfile?
    private(set) var isHydrated = false

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    var hasProfile: Bool {
        profile != nil
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        SparkAvatarCatalog.configureURLCacheIfNeeded()
        profile = Self.loadProfile(from: userDefaults, decoder: decoder)
        migrateLegacyAvatarIfNeeded()
        isHydrated = true
    }

    func createProfile(displayName: String, avatarName: String) {
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.count >= 2 else { return }
        let normalizedAvatar = SparkAvatarCatalog.normalizeAvatarName(avatarName)
        guard SparkAvatarCatalog.isSupportedAvatarName(normalizedAvatar) else { return }

        profile = UserProfile(
            id: Self.generateID(),
            displayName: trimmedName,
            avatarName: normalizedAvatar,
            bio: nil,
            likes: nil,
            dislikes: nil,
            createdAt: Int64(Date().timeIntervalSince1970 * 1000)
        )

        persistProfile()
    }

    func updateProfile(
        displayName: String? = nil,
        avatarName: String? = nil,
        bio: String? = nil,
        likes: String? = nil,
        dislikes: String? = nil
    ) {
        guard var current = profile else { return }

        if let displayName {
            let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.count >= 2, trimmed.count <= 20 else { return }
            current.displayName = trimmed
        }
        if let avatarName {
            current.avatarName = SparkAvatarCatalog.normalizeAvatarName(avatarName)
        }
        if bio != nil {
            let trimmed = bio?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            current.bio = trimmed.isEmpty ? nil : trimmed
        }
        if likes != nil {
            let trimmed = likes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            current.likes = trimmed.isEmpty ? nil : trimmed
        }
        if dislikes != nil {
            let trimmed = dislikes?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            current.dislikes = trimmed.isEmpty ? nil : trimmed
        }

        profile = current
        persistProfile()
    }

    func saveProfileEdit(
        displayName: String,
        avatarName: String,
        bio: String,
        likes: String,
        dislikes: String
    ) -> Bool {
        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.count >= 2, trimmedName.count <= 20 else { return false }
        updateProfile(
            displayName: trimmedName,
            avatarName: avatarName,
            bio: bio,
            likes: likes,
            dislikes: dislikes
        )
        return profile != nil
    }

    /// Clears persisted profile so onboarding can be shown again.
    func reset() {
        profile = nil
        userDefaults.removeObject(forKey: ProfileStorage.key)
    }

    #if DEBUG
    func resetForPreview() {
        reset()
    }
    #endif

    private func migrateLegacyAvatarIfNeeded() {
        guard var current = profile,
              let migrated = SparkAvatarCatalog.migrateLegacyAvatarNameIfNeeded(current.avatarName),
              migrated != current.avatarName else { return }
        current.avatarName = migrated
        profile = current
        persistProfile()
    }

    private func persistProfile() {
        let payload = ProfileStoragePayload(profile: profile)
        do {
            let data = try encoder.encode(payload)
            userDefaults.set(data, forKey: ProfileStorage.key)
        } catch {
            profile = nil
            userDefaults.removeObject(forKey: ProfileStorage.key)
        }
    }

    private static func loadProfile(from userDefaults: UserDefaults, decoder: JSONDecoder) -> UserProfile? {
        guard let data = userDefaults.data(forKey: ProfileStorage.key) else {
            return nil
        }

        do {
            let payload = try decoder.decode(ProfileStoragePayload.self, from: data)
            return payload.profile
        } catch {
            userDefaults.removeObject(forKey: ProfileStorage.key)
            return nil
        }
    }

    private static func generateID() -> String {
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let random = Int.random(in: 0..<1_000_000)
        return "\(timestamp)-\(random)"
    }
}
