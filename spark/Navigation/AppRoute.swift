//
//  AppRoute.swift
//  Spark
//
//  Purpose:
//  Typed navigation destinations reachable from home and shortcuts.
//
//  Responsibilities:
//  • Defines route cases and tab associations for navigation.
//

import Foundation

/// Typed navigation destinations reachable from the home screen and shortcuts.
enum AppRoute: Hashable, Codable {
    case learn
    case reminders
    case dates
    case cycle
    case quests
    case feelings
    case focus
    case profile
    case circle
    case opportunities
    case music
    case timer
    case findThings
    case notificationSettings

    var placeholderTitle: String {
        switch self {
        case .learn: return "Learn about ADHD"
        case .reminders: return "Reminders"
        case .dates: return "Events"
        case .cycle: return "Cycle"
        case .quests: return "Quests"
        case .feelings: return "Feelings"
        case .focus: return "Focus"
        case .profile: return "Me"
        case .circle: return "Spark Circle"
        case .opportunities: return "Discover Opportunities"
        case .music: return "Music"
        case .timer: return "Timer"
        case .findThings: return "Find My Things"
        case .notificationSettings: return "Notification Settings"
        }
    }

    var tab: SparkTab? {
        switch self {
        case .quests: return .quests
        case .focus: return .focus
        case .feelings: return .feelings
        case .profile: return .me
        default: return nil
        }
    }
}
