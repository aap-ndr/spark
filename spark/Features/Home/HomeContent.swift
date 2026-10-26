//
//  HomeContent.swift
//  Spark
//
//  Purpose:
//  Static home screen content and greeting helpers.
//
//  Responsibilities:
//  • Provides affirmations, quick cards, and toolkit tile definitions.
//  • Computes time-based greetings and toolkit styling helpers.
//

import SwiftUI

enum HomeContent {
    static let affirmations = [
        "Your brain is beautifully different — never broken. 💗",
        "You bring a spark no one else can. ✨",
        "Progress, not perfection. Tiny steps count. 🌱",
        "You are allowed to do things your own way. 🌈",
        "Rest is productive too. Be gentle with you. 🍃",
        "You've handled 100% of your hard days so far. 🌟",
        "Being different is your superpower, not your flaw. 💫",
    ]

    private static let greetingSets: [String: [String]] = [
        "morning": ["Morning, sunshine", "Rise & shine", "Hey, early bird", "Good morning, you"],
        "day": ["Hey you", "What's up", "Heyy", "Hi again"],
        "evening": ["Evening vibes", "Hey, night owl", "Winding down?", "Hey you"],
    ]

    static func greeting(now: Date = Date()) -> String {
        let hour = Calendar.current.component(.hour, from: now)
        let slot = hour < 12 ? "morning" : hour < 18 ? "day" : "evening"
        let bucket = Int(now.timeIntervalSince1970 * 1000 / 3_600_000)
        let options = greetingSets[slot] ?? greetingSets["day"] ?? ["Hey you"]
        return options[bucket % options.count]
    }

    static func affirmation(now: Date = Date()) -> String {
        let dayIndex = Int(now.timeIntervalSince1970 * 1000 / 86_400_000) % affirmations.count
        return affirmations[dayIndex]
    }

    struct QuickCardItem: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let gradient: SparkGradientPreset
        let route: AppRoute
    }

    struct ToolkitTileItem: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let gradient: SparkGradientPreset
        let route: AppRoute
        var filledIcon: Bool = false
    }

    static let quickCards: [QuickCardItem] = [
        QuickCardItem(
            title: "Spark Circle",
            subtitle: "Send love to your people",
            icon: "person.3.fill",
            gradient: .dream,
            route: .circle
        ),
        QuickCardItem(
            title: "Discover Opportunities",
            subtitle: "Camps, clubs & competitions",
            icon: "safari.fill",
            gradient: .garden,
            route: .opportunities
        ),
    ]

    static let epicTiles: [ToolkitTileItem] = [
        ToolkitTileItem(title: "Quests", icon: "checklist", gradient: .sunrise, route: .quests),
        ToolkitTileItem(title: "Focus", icon: "timer", gradient: .ocean, route: .focus),
        ToolkitTileItem(title: "Feelings", icon: "face.smiling", gradient: .garden, route: .feelings),
        ToolkitTileItem(title: "Cycle", icon: "drop.fill", gradient: .berry, route: .cycle, filledIcon: true),
        ToolkitTileItem(title: "Music", icon: "headphones", gradient: .lavender, route: .music),
        ToolkitTileItem(title: "Events", icon: "calendar.badge.clock", gradient: .twilight, route: .dates),
        ToolkitTileItem(title: "Timer", icon: "alarm.fill", gradient: .coral, route: .timer),
        ToolkitTileItem(title: "Find My Things", icon: "shippingbox.fill", gradient: .mint, route: .findThings),
        ToolkitTileItem(title: "Reminders", icon: "bell.badge.fill", gradient: .dream, route: .reminders),
        ToolkitTileItem(title: "Learn about ADHD", icon: "brain.head.profile", gradient: .pink, route: .learn),
    ]

    static func toolkitWashColor(for preset: SparkGradientPreset) -> Color {
        preset.colors.first?.opacity(0.15) ?? SparkColors.cream
    }
}

struct SparkFadeInDown: ViewModifier {
    let delay: Double
    let duration: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible || reduceMotion ? 0 : 12)
            .onAppear {
                guard !reduceMotion else {
                    isVisible = true
                    return
                }
                withAnimation(.easeOut(duration: duration).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func sparkFadeInDown(delay: Double = 0, duration: Double = 0.45) -> some View {
        modifier(SparkFadeInDown(delay: delay, duration: duration))
    }
}
