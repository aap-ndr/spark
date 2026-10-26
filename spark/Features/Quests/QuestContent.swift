//
//  QuestContent.swift
//  Spark
//
//  Purpose:
//  Static quest feature styling and helper content.
//
//  Responsibilities:
//  • Provides quest gradients, spacing, and copy constants.
//

import Foundation

enum QuestContent {
    static let emojiChoices = ["✨", "☀️", "📚", "🧺", "🌞", "🎨", "💪", "🌈", "🎯", "💧", "🌸", "⭐"]

    static let gradientKeys = ["lavender", "mint", "pink", "sunrise", "ocean", "garden", "dream"]

    static let rowGap: CGFloat = 16

    struct QuestTemplate: Identifiable {
        let id = UUID()
        let title: String
        let emoji: String
        let color: String
        let steps: [String]
    }

    static let templates: [QuestTemplate] = [
        QuestTemplate(
            title: "Study session",
            emoji: "📚",
            color: "ocean",
            steps: ["Clear my space", "Set a 15-min timer", "Do one small chunk", "Take a stretch break"]
        ),
        QuestTemplate(
            title: "Tidy my space",
            emoji: "🧺",
            color: "garden",
            steps: ["Pick up trash", "Put clothes away", "Clear my desk"]
        ),
        QuestTemplate(
            title: "Get ready",
            emoji: "🌞",
            color: "sunrise",
            steps: ["Drink water", "Brush teeth", "Get dressed", "Pack my bag"]
        ),
    ]

    static func formatReminder(milliseconds: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
        let now = Date()
        let calendar = Calendar.current
        let sameDay = calendar.isDate(date, inSameDayAs: now)
        let time = date.formatted(date: .omitted, time: .shortened)
        if sameDay {
            return "Today \(time)"
        }
        let day = date.formatted(.dateTime.month(.abbreviated).day())
        return "\(day) · \(time)"
    }

    static func gradientKey(forQuestCount count: Int) -> String {
        gradientKeys[count % gradientKeys.count]
    }
}
