//
//  FeelingsContent.swift
//  Spark
//
//  Purpose:
//  Static feelings feature copy and mood definitions.
//
//  Responsibilities:
//  • Provides mood labels, colors, and toolkit content.
//

import SwiftUI

struct FeelingOption: Identifiable, Equatable {
    let mood: String
    let emoji: String
    let color: Color

    var id: String { mood }
}

enum FeelingsContent {
    static let feelings: [FeelingOption] = [
        FeelingOption(mood: "Happy", emoji: "😊", color: SparkColors.yellowSoft),
        FeelingOption(mood: "Calm", emoji: "😌", color: SparkColors.mintSoft),
        FeelingOption(mood: "Excited", emoji: "🤩", color: SparkColors.pinkSoft),
        FeelingOption(mood: "Meh", emoji: "😐", color: SparkColors.lavenderSoft),
        FeelingOption(mood: "Anxious", emoji: "😰", color: SparkColors.skySoft),
        FeelingOption(mood: "Sad", emoji: "😢", color: SparkColors.skySoft),
        FeelingOption(mood: "Frustrated", emoji: "😤", color: SparkColors.peachSoft),
        FeelingOption(mood: "Overwhelmed", emoji: "😵‍💫", color: SparkColors.lavenderSoft),
        FeelingOption(mood: "Nervous", emoji: "😬", color: SparkColors.skySoft),
        FeelingOption(mood: "Stressed", emoji: "😩", color: SparkColors.peachSoft),
        FeelingOption(mood: "Tired", emoji: "🥱", color: SparkColors.lavenderSoft),
        FeelingOption(mood: "Lonely", emoji: "🥺", color: SparkColors.skySoft),
        FeelingOption(mood: "Confident", emoji: "😎", color: SparkColors.yellowSoft),
        FeelingOption(mood: "Grateful", emoji: "🥰", color: SparkColors.mintSoft),
    ]

    static let affirmations = [
        "Whatever you feel right now is allowed. 💗",
        "You are not your hardest day. 🌈",
        "Feelings are visitors — they come and go. 🍃",
        "You've survived every tough moment so far. 🌟",
        "Being gentle with yourself is brave. 🌸",
    ]

    static let moodDotColors: [String: Color] = [
        "Happy": SparkColors.yellow,
        "Calm": SparkColors.mint,
        "Excited": SparkColors.pink,
        "Meh": SparkColors.lavender,
        "Anxious": SparkColors.sky,
        "Sad": SparkColors.sky,
        "Frustrated": SparkColors.peach,
        "Overwhelmed": SparkColors.lavender,
        "Nervous": SparkColors.sky,
        "Stressed": SparkColors.peach,
        "Tired": SparkColors.lavender,
        "Lonely": SparkColors.sky,
        "Confident": SparkColors.yellow,
        "Grateful": SparkColors.mint,
    ]

    static func moodDotColor(for mood: String) -> Color {
        moodDotColors[mood] ?? SparkColors.lavender
    }

    static func feeling(for mood: String) -> FeelingOption? {
        feelings.first { $0.mood == mood }
    }
}
