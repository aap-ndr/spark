//
//  SparkTheme.swift
//  Spark
//
//  Purpose:
//  Gradient presets and theme helpers used across screens.
//
//  Responsibilities:
//  • Defines named gradient combinations for cards and buttons.
//  • Bridges skin selections to visual styling tokens.
//

import SwiftUI

enum SparkGradientPreset: CaseIterable {
    case lavender
    case mint
    case garden
    case pink
    case sunrise
    case ocean
    case dream
    case twilight
    case coral
    case berry

    var colors: [Color] {
        switch self {
        case .lavender:
            return [Color(sparkHex: 0x7A31E6), Color(sparkHex: 0x4E12AE)]
        case .mint:
            return [Color(sparkHex: 0x12B096), Color(sparkHex: 0x097C74)]
        case .garden:
            return [Color(sparkHex: 0x26BC94), Color(sparkHex: 0x0F9E88)]
        case .pink:
            return [Color(sparkHex: 0xE6357C), Color(sparkHex: 0xB90F5B)]
        case .sunrise:
            return [Color(sparkHex: 0xE89B2F), Color(sparkHex: 0xE84D52)]
        case .ocean:
            return [Color(sparkHex: 0x3479E0), Color(sparkHex: 0x4E40E0)]
        case .dream:
            return [Color(sparkHex: 0x8A3EE6), Color(sparkHex: 0xD61E6C)]
        case .twilight:
            return [Color(sparkHex: 0x2A1E63), Color(sparkHex: 0x6E51BE)]
        case .coral:
            return [Color(sparkHex: 0xF0785C), Color(sparkHex: 0xE0455F)]
        case .berry:
            return [Color(sparkHex: 0xB01E63), Color(sparkHex: 0x7A1150)]
        }
    }

    var linearGradient: LinearGradient {
        LinearGradient(
            colors: colors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

enum SparkTheme {
    static let primaryButtonGradient = LinearGradient(
        colors: [SparkColors.lavender, SparkColors.primaryButtonGradientEnd],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func gradient(_ preset: SparkGradientPreset) -> LinearGradient {
        preset.linearGradient
    }

    static func gradient(forKey key: String) -> LinearGradient {
        switch key {
        case "lavender": return gradient(.lavender)
        case "mint": return gradient(.mint)
        case "garden": return gradient(.garden)
        case "pink": return gradient(.pink)
        case "sunrise": return gradient(.sunrise)
        case "ocean": return gradient(.ocean)
        case "dream": return gradient(.dream)
        case "twilight": return gradient(.twilight)
        case "coral": return gradient(.coral)
        case "berry": return gradient(.berry)
        default: return gradient(.lavender)
        }
    }
}

struct SparkSoftShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(
            color: SparkColors.softShadowColor.opacity(0.14),
            radius: 20,
            x: 0,
            y: 10
        )
    }
}

struct SparkAvatarShadow: ViewModifier {
    func body(content: Content) -> some View {
        content.shadow(
            color: SparkColors.avatarShadowColor.opacity(0.3),
            radius: 9,
            x: 0,
            y: 4
        )
    }
}

extension View {
    func sparkSoftShadow() -> some View {
        modifier(SparkSoftShadow())
    }

    func sparkAvatarShadow() -> some View {
        modifier(SparkAvatarShadow())
    }
}
