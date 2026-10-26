//
//  SparkAvatarCatalog.swift
//  Spark
//
//  Purpose:
//  Shared avatar catalog and DiceBear URL helpers.
//
//  Responsibilities:
//  • Defines preset avatars and builder configuration encoding.
//  • Normalizes avatar names and URL cache configuration.
//

import Foundation
import SwiftUI

/// Shared avatar catalog: DiceBear Avataaars presets and custom builder support.
struct AvatarConfig: Equatable {
    var skinColor: String
    var top: String
    var covering: String?
    var hairColor: String
    var accessory: String?
    var clothesColor: String
    var backgroundColor: String
}

enum SparkAvatarCatalog {
    private static let dbxPrefix = "dbx:"
    private static let imgPrefix = "img:"
    private static let fixedSeed = "spark"

    static let skinTones = ["ffdbb4", "edb98a", "d08b5b", "ae5d29", "7a4a34", "614335"]

    static let hairstyles = [
        "straight01", "straight02", "straightAndStrand", "longButNotTooLong", "bigHair",
        "curvy", "curly", "bob", "miaWallace", "bun", "frida", "shortCurly", "frizzle",
        "fro", "froBand", "dreads",
    ]

    static let hairColors = [
        "2c1b18", "4a312c", "724133", "a55728", "b58143", "d6b370", "ecdcbf", "e8e1e1",
        "c93305", "e07a9c", "9b6dd6", "6db1e0",
    ]

    static let coverings: [String?] = [nil, "hijab", "turban", "winterHat1"]

    static let accessories: [String?] = [nil, "round", "wayfarers", "prescription01", "prescription02", "sunglasses"]

    static let clothesColors = ["ff6ea8", "ff8f6b", "ffd15c", "7ed957", "5bc6e8", "8f9dff", "c78fff"]

    static let backgroundColors = ["eee6ff", "ffe1ee", "d6f5ef", "dceaff", "fff0d4", "ffe2e1", "transparent"]

    static let defaultConfig = AvatarConfig(
        skinColor: "edb98a",
        top: "longButNotTooLong",
        covering: nil,
        hairColor: "4a312c",
        accessory: nil,
        clothesColor: "5bc6e8",
        backgroundColor: "eee6ff"
    )

    static let presets: [AvatarConfig] = [
        AvatarConfig(skinColor: "ffdbb4", top: "straight01", covering: nil, hairColor: "2c1b18", accessory: nil, clothesColor: "ff6ea8", backgroundColor: "ffe1ee"),
        AvatarConfig(skinColor: "edb98a", top: "bigHair", covering: nil, hairColor: "724133", accessory: "round", clothesColor: "8f9dff", backgroundColor: "dceaff"),
        AvatarConfig(skinColor: "edb98a", top: "straight02", covering: "hijab", hairColor: "2c1b18", accessory: nil, clothesColor: "7ed957", backgroundColor: "d6f5ef"),
        AvatarConfig(skinColor: "ae5d29", top: "fro", covering: nil, hairColor: "2c1b18", accessory: nil, clothesColor: "ffd15c", backgroundColor: "fff0d4"),
        AvatarConfig(skinColor: "614335", top: "dreads", covering: nil, hairColor: "2c1b18", accessory: nil, clothesColor: "5bc6e8", backgroundColor: "dceaff"),
        AvatarConfig(skinColor: "d08b5b", top: "curly", covering: nil, hairColor: "a55728", accessory: nil, clothesColor: "ff8f6b", backgroundColor: "ffe2e1"),
        AvatarConfig(skinColor: "ffdbb4", top: "longButNotTooLong", covering: nil, hairColor: "e07a9c", accessory: nil, clothesColor: "c78fff", backgroundColor: "eee6ff"),
        AvatarConfig(skinColor: "edb98a", top: "bun", covering: nil, hairColor: "4a312c", accessory: "wayfarers", clothesColor: "7ed957", backgroundColor: "d6f5ef"),
        AvatarConfig(skinColor: "d08b5b", top: "straight01", covering: "turban", hairColor: "2c1b18", accessory: nil, clothesColor: "ff6ea8", backgroundColor: "ffe1ee"),
        AvatarConfig(skinColor: "edb98a", top: "frida", covering: nil, hairColor: "4a312c", accessory: nil, clothesColor: "ffd15c", backgroundColor: "fff0d4"),
    ]

    static var defaultAvatarName: String {
        encode(defaultConfig)
    }

    static var encodedPresets: [String] {
        presets.map(encode)
    }

    /// Default avatar selected during onboarding.
    static var defaultOnboardingAvatarName: String {
        encodedPresets.first ?? defaultAvatarName
    }

    static let legacyMonogramIDs: [String] = [
        "nova", "luna", "sage", "ruby", "iris", "zara", "mia", "ada", "kai", "zoe", "ember", "juno",
    ]

    static let legacyMigrationMap: [String: Int] = [
        "nova": 0,
        "luna": 1,
        "sage": 2,
        "ruby": 3,
        "iris": 4,
        "zara": 5,
        "mia": 6,
        "ada": 7,
        "kai": 8,
        "zoe": 9,
        "ember": 6,
        "juno": 7,
    ]

    static func isLegacyMonogram(_ avatarName: String?) -> Bool {
        guard let avatarName else { return false }
        let normalized = avatarName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return legacyMigrationMap[normalized] != nil
    }

    static func isSupportedAvatarName(_ avatarName: String) -> Bool {
        isPhotoAvatar(avatarName) || isCustomAvatar(avatarName)
    }

    static func normalizeAvatarName(_ avatarName: String) -> String {
        if isPhotoAvatar(avatarName) || isCustomAvatar(avatarName) {
            return avatarName
        }

        let normalized = avatarName.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let presetIndex = legacyMigrationMap[normalized], presets.indices.contains(presetIndex) {
            return encode(presets[presetIndex])
        }

        return defaultAvatarName
    }

    static func migrateLegacyAvatarNameIfNeeded(_ avatarName: String) -> String? {
        guard isLegacyMonogram(avatarName) else { return nil }
        return normalizeAvatarName(avatarName)
    }

    static func resolvedConfig(for avatarName: String?) -> AvatarConfig {
        decode(normalizeAvatarName(avatarName ?? "")) ?? defaultConfig
    }

    static func configureURLCacheIfNeeded() {
        URLCache.shared = URLCache(
            memoryCapacity: 20_000_000,
            diskCapacity: 100_000_000,
            diskPath: "spark-avatar-cache"
        )
    }

    static func placeholderColor(for config: AvatarConfig) -> Color {
        if config.backgroundColor == "transparent" {
            return SparkColors.lavenderSoft
        }
        return Color(sparkHex: UInt(config.backgroundColor, radix: 16) ?? 0xEEE6FF)
    }

    static func decode(_ avatarName: String?) -> AvatarConfig? {
        guard let avatarName, avatarName.hasPrefix(dbxPrefix) else { return nil }
        let query = String(avatarName.dropFirst(dbxPrefix.count))
        guard let components = URLComponents(string: "?\(query)") else { return nil }
        let items = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).map { ($0.name, $0.value ?? "") })

        func string(_ key: String, fallback: String) -> String {
            let value = items[key] ?? ""
            return value.isEmpty ? fallback : value
        }

        func optional(_ key: String) -> String? {
            let value = items[key] ?? ""
            return value.isEmpty ? nil : value
        }

        return AvatarConfig(
            skinColor: string("skinColor", fallback: defaultConfig.skinColor),
            top: string("top", fallback: defaultConfig.top),
            covering: optional("covering"),
            hairColor: string("hairColor", fallback: defaultConfig.hairColor),
            accessory: optional("accessory"),
            clothesColor: string("clothesColor", fallback: defaultConfig.clothesColor),
            backgroundColor: string("backgroundColor", fallback: defaultConfig.backgroundColor)
        )
    }

    static func encode(_ config: AvatarConfig) -> String {
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "skinColor", value: config.skinColor),
            URLQueryItem(name: "top", value: config.top),
            URLQueryItem(name: "covering", value: config.covering ?? ""),
            URLQueryItem(name: "hairColor", value: config.hairColor),
            URLQueryItem(name: "accessory", value: config.accessory ?? ""),
            URLQueryItem(name: "clothesColor", value: config.clothesColor),
            URLQueryItem(name: "backgroundColor", value: config.backgroundColor),
        ]
        let query = components.percentEncodedQuery ?? ""
        return dbxPrefix + query
    }

    static func encodePhoto(_ filePath: String) -> String {
        imgPrefix + filePath
    }

    static func photoURI(from avatarName: String?) -> String? {
        guard let avatarName, avatarName.hasPrefix(imgPrefix) else { return nil }
        return String(avatarName.dropFirst(imgPrefix.count))
    }

    static func isPhotoAvatar(_ avatarName: String?) -> Bool {
        avatarName?.hasPrefix(imgPrefix) == true
    }

    static func isCustomAvatar(_ avatarName: String?) -> Bool {
        avatarName?.hasPrefix(dbxPrefix) == true
    }

    static func url(for config: AvatarConfig, size: Int) -> URL? {
        let px = max(1, size)
        var components = URLComponents(string: "https://api.dicebear.com/9.x/avataaars/png")
        var items: [URLQueryItem] = [
            URLQueryItem(name: "seed", value: fixedSeed),
            URLQueryItem(name: "size", value: String(px)),
            URLQueryItem(name: "top", value: config.covering ?? config.top),
            URLQueryItem(name: "hairColor", value: config.hairColor),
            URLQueryItem(name: "skinColor", value: config.skinColor),
            URLQueryItem(name: "eyes", value: "default"),
            URLQueryItem(name: "eyebrows", value: "default"),
            URLQueryItem(name: "mouth", value: "smile"),
            URLQueryItem(name: "facialHairProbability", value: "0"),
            URLQueryItem(name: "clothing", value: "shirtScoopNeck"),
            URLQueryItem(name: "clothesColor", value: config.clothesColor),
        ]

        if let accessory = config.accessory {
            items.append(URLQueryItem(name: "accessories", value: accessory))
            items.append(URLQueryItem(name: "accessoriesProbability", value: "100"))
        } else {
            items.append(URLQueryItem(name: "accessoriesProbability", value: "0"))
        }

        if config.backgroundColor == "transparent" {
            items.append(URLQueryItem(name: "backgroundColor", value: "transparent"))
        } else {
            items.append(URLQueryItem(name: "backgroundColor", value: config.backgroundColor))
            items.append(URLQueryItem(name: "backgroundType", value: "solid"))
        }

        components?.queryItems = items
        return components?.url
    }

    static func coveringLabel(_ id: String) -> String {
        switch id {
        case "hijab": return "Hijab"
        case "turban": return "Turban"
        case "winterHat1": return "Beanie"
        default: return id
        }
    }

    static func accessoryLabel(_ id: String) -> String {
        switch id {
        case "round": return "Round"
        case "wayfarers": return "Wayfarers"
        case "prescription01": return "Glasses"
        case "prescription02": return "Glasses 2"
        case "sunglasses": return "Sunglasses"
        default: return id
        }
    }
}
