//
//  CircleContent.swift
//  Spark
//
//  Purpose:
//  Static Spark Circle demo content and copy.
//
//  Responsibilities:
//  • Provides seeded members and circle-related constants.
//

import Foundation

enum CircleContent {
    static let emojis = ["🌸", "✨", "🌈", "💫", "🦋", "🌻", "💗", "🌙"]

    static let autoReplies = [
        "Aww thank you!! Right back at you 💗",
        "You just made my whole day ✨",
        "The BEST. Sending it right back 🌈",
    ]

    static let whenQuickPicks = ["Right now", "In 1 hour", "Tonight", "After school"]

    static let safetyBanner =
        "Circles are invite-only. Be kind — you can block or report anytime."

    static func inviteMessage(circleName: String, inviteCode: String) -> String {
        "Join my Spark Circle \"\(circleName)\" 💗 Open the Spark app and enter code \(inviteCode) to join me!"
    }

    /// Seeded demo circle members bundled with the app.
    static let seedFriends: [SparkCircleMember] = [
        SparkCircleMember(
            id: "f1",
            displayName: "Maya",
            avatarName: "dbx:skinColor=ffdbb4&top=straight01&covering=&hairColor=2c1b18&accessory=&clothesColor=ff6ea8&backgroundColor=ffe1ee"
        ),
        SparkCircleMember(
            id: "f2",
            displayName: "Priya",
            avatarName: "dbx:skinColor=edb98a&top=straight02&covering=hijab&hairColor=2c1b18&accessory=&clothesColor=7ed957&backgroundColor=d6f5ef"
        ),
        SparkCircleMember(
            id: "f3",
            displayName: "Grace",
            avatarName: "dbx:skinColor=d08b5b&top=curly&covering=&hairColor=a55728&accessory=&clothesColor=ff8f6b&backgroundColor=ffe2e1"
        ),
    ]

    static let joinDemoCircleName = "Sunshine Squad"
    static let joinDemoCircleEmoji = "🌻"

    static func randomAutoReply() -> String {
        autoReplies.randomElement() ?? autoReplies[0]
    }
}
