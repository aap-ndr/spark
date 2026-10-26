//
//  SparkLibrary.swift
//  Spark
//
//  Purpose:
//  Spark message templates and library content.
//
//  Responsibilities:
//  • Provides preset spark copy and emoji suggestions.
//

import Foundation

enum SparkVibe: String, CaseIterable, Codable {
    case cheer
    case proud
    case comfort
    case needSpark
}

struct SparkTemplate: Identifiable, Equatable {
    let id: String
    let text: String
    let vibe: SparkVibe
}

enum SparkLibrary {
    static let vibeLabels: [SparkVibe: String] = [
        .cheer: "Cheer them on",
        .proud: "I'm proud of you",
        .comfort: "Gentle comfort",
        .needSpark: "I need a Spark",
    ]

    static let templates: [SparkTemplate] = [
        SparkTemplate(id: "s1", text: "You've got this — I believe in you! ✨", vibe: .cheer),
        SparkTemplate(id: "s2", text: "Sending you the biggest burst of good energy today 🌟", vibe: .cheer),
        SparkTemplate(id: "s3", text: "Reminder: you are magic, even on the messy days 💛", vibe: .comfort),
        SparkTemplate(id: "s4", text: "So proud of you for showing up. That counts. 🌈", vibe: .proud),
        SparkTemplate(id: "s5", text: "Your brain is beautifully different, never broken 🧠💗", vibe: .comfort),
        SparkTemplate(id: "s6", text: "Tiny steps still move you forward. Go you! 🐛→🦋", vibe: .cheer),
        SparkTemplate(id: "s7", text: "You did a hard thing today and I noticed 👑", vibe: .proud),
        SparkTemplate(id: "s8", text: "It's okay to rest. You're still worthy. 🌙", vibe: .comfort),
        SparkTemplate(id: "s9", text: "Could really use a spark today 🥺 send some love?", vibe: .needSpark),
        SparkTemplate(id: "s10", text: "Low battery over here — cheer me on? 🔋💗", vibe: .needSpark),
        SparkTemplate(id: "s11", text: "You make the world brighter just by being you ☀️", vibe: .cheer),
        SparkTemplate(id: "s12", text: "Whatever happens, we ride the wave together 🌊", vibe: .comfort),
    ]

    static func templates(for vibe: SparkVibe) -> [SparkTemplate] {
        templates.filter { $0.vibe == vibe }
    }
}
