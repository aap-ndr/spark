//
//  SparkSkin.swift
//  Spark
//
//  Purpose:
//  Selectable app skins and environment propagation.
//
//  Responsibilities:
//  • Catalogs available skin gradients and wash colors.
//  • Exposes the active skin through SwiftUI environment values.
//

import SwiftUI

struct SparkSkin: Identifiable {
    let id: String
    let name: String
    let tagline: String
    let emoji: String
    let accent: Color
    let accentSoft: Color
    let gradient: LinearGradient
    let wash: LinearGradient
}

enum SparkSkinCatalog {
    static let all: [SparkSkin] = [
        SparkSkin(
            id: "default",
            name: "Spark",
            tagline: "The original violet glow",
            emoji: "✨",
            accent: SparkColors.lavender,
            accentSoft: SparkColors.lavenderSoft,
            gradient: SparkTheme.gradient(.dream),
            wash: LinearGradient(
                colors: [SparkColors.lavenderSoft, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
        ),
        SparkSkin(
            id: "forest",
            name: "Enchanted Forest",
            tagline: "Calm, green & grounded",
            emoji: "🌲",
            accent: SparkColors.mint,
            accentSoft: SparkColors.mintSoft,
            gradient: SparkTheme.gradient(.garden),
            wash: LinearGradient(
                colors: [SparkColors.mintSoft, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
        ),
        SparkSkin(
            id: "ocean",
            name: "Ocean Calm",
            tagline: "Cool blues & deep focus",
            emoji: "🌊",
            accent: SparkColors.sky,
            accentSoft: SparkColors.skySoft,
            gradient: SparkTheme.gradient(.ocean),
            wash: LinearGradient(
                colors: [SparkColors.skySoft, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
        ),
        SparkSkin(
            id: "starlit",
            name: "Starlit Sky",
            tagline: "Deep dreamy indigo twilight",
            emoji: "🌙",
            accent: Color(sparkHex: 0x5B45B0),
            accentSoft: SparkColors.indigoSoft,
            gradient: SparkTheme.gradient(.twilight),
            wash: LinearGradient(
                colors: [SparkColors.indigoSoft, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
        ),
        SparkSkin(
            id: "sunrise",
            name: "Cloud Kingdom",
            tagline: "Warm gold & coral skies",
            emoji: "☁️",
            accent: SparkColors.peach,
            accentSoft: SparkColors.peachSoft,
            gradient: SparkTheme.gradient(.sunrise),
            wash: LinearGradient(
                colors: [SparkColors.yellowSoft, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
        ),
    ]

    static let defaultSkin = all[0]

    static func skin(id: String?) -> SparkSkin {
        guard let id else { return defaultSkin }
        return all.first(where: { $0.id == id }) ?? defaultSkin
    }
}

private struct SparkSkinKey: EnvironmentKey {
    static let defaultValue = SparkSkinCatalog.defaultSkin
}

extension EnvironmentValues {
    var sparkSkin: SparkSkin {
        get { self[SparkSkinKey.self] }
        set { self[SparkSkinKey.self] = newValue }
    }
}
