//
//  TimerSounds.swift
//  Spark
//
//  Purpose:
//  Timer sound metadata for completion alerts.
//
//  Responsibilities:
//  • Defines available alarm sound options for the timer feature.
//

import Foundation

struct TimerSound: Identifiable, Equatable {
    let id: String
    let label: String
    let url: URL?
}

enum TimerSounds {
    static let defaultSoundID = "gentle-chime"

    static let all: [TimerSound] = [
        TimerSound(
            id: "gentle-chime",
            label: "Gentle chime",
            url: URL(string: "https://assets.mixkit.co/active_storage/sfx/2869/2869.wav")
        ),
        TimerSound(
            id: "soft-bell",
            label: "Soft bell",
            url: URL(string: "https://assets.mixkit.co/active_storage/sfx/1005/1005.wav")
        ),
        TimerSound(
            id: "marimba",
            label: "Marimba",
            url: URL(string: "https://assets.mixkit.co/active_storage/sfx/933/933.wav")
        ),
        TimerSound(
            id: "bright-tones",
            label: "Bright tones",
            url: URL(string: "https://assets.mixkit.co/active_storage/sfx/995/995.wav")
        ),
        TimerSound(
            id: "vibrate-only",
            label: "Vibrate only",
            url: nil
        ),
    ]

    static let presets = [5, 10, 15, 25, 45, 60]
    static let minMinutes = 1
    static let maxMinutes = 180

    static func sound(for id: String) -> TimerSound {
        all.first { $0.id == id } ?? all[0]
    }
}
