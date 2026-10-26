//
//  FocusContent.swift
//  Spark
//
//  Purpose:
//  Static focus feature copy and realm definitions.
//
//  Responsibilities:
//  • Provides realm metadata, gradients, and focus UI constants.
//

import SwiftUI

enum FocusRealmID: String, CaseIterable, Identifiable, Codable {
    case forest
    case library
    case ocean
    case starlit
    case clouds

    var id: String { rawValue }
}

struct FocusRealm: Identifiable, Equatable {
    let id: FocusRealmID
    let name: String
    let emoji: String
    let gradient: SparkGradientPreset
    let ringColor: Color
    let ambient: String
    let affirmation: String
    let trackID: String
    let backdrop: [Color]
    let particleKind: FocusParticleKind
    let particleGlyphs: [String]
    let tint: Color
}

enum FocusParticleKind {
    case leaf
    case bubble
    case star
    case cloud
    case mote
}

enum FocusContent {
    static let durations = [10, 15, 25, 45]

    static let encouragements = [
        "You're doing so well 💗",
        "Staying with it, one breath at a time 🌸",
        "Distractions can wait — you've got this ✨",
        "Proud of you for showing up 🌟",
        "Soft focus, steady heart 🍃",
    ]

    static let ringSize: CGFloat = 250
    static let stroke: CGFloat = 14
    static let sceneHeight: CGFloat = 430

    static var ringRadius: CGFloat {
        (ringSize - stroke) / 2
    }

    static var circumference: CGFloat {
        2 * .pi * ringRadius
    }

    static let realms: [FocusRealm] = [
        FocusRealm(
            id: .forest,
            name: "Enchanted Forest",
            emoji: "🌲",
            gradient: .garden,
            ringColor: Color(sparkHex: 0xB6F5DE),
            ambient: "Leaves drift softly. The forest breathes with you.",
            affirmation: "I'm focusing right here with you 🌸",
            trackID: "willow-and-the-light",
            backdrop: [Color(sparkHex: 0x1F6E52), Color(sparkHex: 0x2CA57E), Color(sparkHex: 0xD9F3E8)],
            particleKind: .leaf,
            particleGlyphs: ["🍃", "🌿", "🍂"],
            tint: Color(sparkHex: 0x14785A).opacity(0.12)
        ),
        FocusRealm(
            id: .library,
            name: "Cozy Library",
            emoji: "📖",
            gradient: .sunrise,
            ringColor: Color(sparkHex: 0xFFE0B0),
            ambient: "Warm lamplight and quiet pages. Just you and this moment.",
            affirmation: "One page, one breath, one moment at a time 📖",
            trackID: "relaxing-piano-music",
            backdrop: [Color(sparkHex: 0x8A4B1F), Color(sparkHex: 0xD98A3D), Color(sparkHex: 0xFBE9CE)],
            particleKind: .mote,
            particleGlyphs: ["✦", "·", "✧"],
            tint: Color(sparkHex: 0x965A28).opacity(0.10)
        ),
        FocusRealm(
            id: .ocean,
            name: "Ocean Calm",
            emoji: "🌊",
            gradient: .ocean,
            ringColor: Color(sparkHex: 0xBFE0FF),
            ambient: "Bubbles rise slowly. Let each one carry a worry away.",
            affirmation: "Let each wave carry a little worry away 🌊",
            trackID: "ocean-waves",
            backdrop: [Color(sparkHex: 0x1E4F94), Color(sparkHex: 0x2D7DF6), Color(sparkHex: 0xDCEAFF)],
            particleKind: .bubble,
            particleGlyphs: ["○", "◦", "°"],
            tint: Color(sparkHex: 0x1E5AB4).opacity(0.12)
        ),
        FocusRealm(
            id: .starlit,
            name: "Starlit Sky",
            emoji: "🌙",
            gradient: .dream,
            ringColor: Color(sparkHex: 0xE4C6FF),
            ambient: "Stars twinkle above. You are exactly where you need to be.",
            affirmation: "You are exactly where you need to be ✨",
            trackID: "meditation-impromptu-01",
            backdrop: [Color(sparkHex: 0x241141), Color(sparkHex: 0x5B2E8F), Color(sparkHex: 0xB98CE6)],
            particleKind: .star,
            particleGlyphs: ["✦", "✧", "⋆", "·"],
            tint: Color(sparkHex: 0x1E0A3C).opacity(0.18)
        ),
        FocusRealm(
            id: .clouds,
            name: "Cloud Kingdom",
            emoji: "☁️",
            gradient: .lavender,
            ringColor: Color(sparkHex: 0xE7DBFF),
            ambient: "Soft clouds float by. No rush up here — just calm.",
            affirmation: "Soft and steady — no rush, just us ☁️",
            trackID: "healing",
            backdrop: [Color(sparkHex: 0x5C7CC9), Color(sparkHex: 0x9FB8F0), Color(sparkHex: 0xEAF0FF)],
            particleKind: .cloud,
            particleGlyphs: ["☁️", "⛅", "☁️"],
            tint: Color(sparkHex: 0x788CDC).opacity(0.10)
        ),
    ]

    static func realm(for id: FocusRealmID) -> FocusRealm {
        realms.first(where: { $0.id == id }) ?? realms[0]
    }

    static func formatTime(seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%d:%02d", minutes, secs)
    }
}
