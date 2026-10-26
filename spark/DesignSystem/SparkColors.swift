//
//  SparkColors.swift
//  Spark
//
//  Purpose:
//  Central color palette for the Spark design system.
//
//  Responsibilities:
//  • Defines brand, surface, text, and shadow colors.
//  • Provides hex helpers for consistent Color construction.
//

import SwiftUI

enum SparkColors {
    // App backgrounds
    static let cream = Color(sparkHex: 0xFBF7FB)
    static let card = Color(sparkHex: 0xFFFFFF)

    // Brand accent colors
    static let lavender = Color(sparkHex: 0x6B26D6)
    static let lavenderSoft = Color(sparkHex: 0xEBE3FB)
    static let mint = Color(sparkHex: 0x0F9E88)
    static let mintSoft = Color(sparkHex: 0xD2F0EA)
    static let pink = Color(sparkHex: 0xD61E6C)
    static let pinkSoft = Color(sparkHex: 0xFBDCE8)
    static let yellow = Color(sparkHex: 0xE0951C)
    static let yellowSoft = Color(sparkHex: 0xFBEBCC)
    static let peach = Color(sparkHex: 0xE84D52)
    static let peachSoft = Color(sparkHex: 0xFBDCDB)
    static let sky = Color(sparkHex: 0x276FDB)
    static let skySoft = Color(sparkHex: 0xD6E4FB)
    static let indigoSoft = Color(sparkHex: 0xE4E0FA)

    // Primary text colors
    static let ink = Color(sparkHex: 0x1E1230)
    static let inkSoft = Color(sparkHex: 0x6C5F84)
    static let white = Color(sparkHex: 0xFFFFFF)

    // Card dividers and list separators
    static let divider = cream

    // Form field and checkbox borders
    static let inputBorderInactive = Color(sparkHex: 0xF0ECFA)
    static let inputBorderCheckboxInactive = Color(sparkHex: 0xDAD2EE)

    // Shared card and avatar shadow tints
    static let softShadowColor = Color(sparkHex: 0x40197D)
    static let avatarShadowColor = Color(sparkHex: 0x8A3EE6)

    // Default primary button gradient end
    static let primaryButtonGradientEnd = Color(sparkHex: 0xA88CFF)
}

extension Color {
    init(sparkHex hex: UInt, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}
