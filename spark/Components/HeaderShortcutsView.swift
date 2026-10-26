//
//  HeaderShortcutsView.swift
//  Spark
//
//  Purpose:
//  Header shortcut buttons for cross-feature navigation.
//
//  Responsibilities:
//  • Renders compact navigation chips from tab header areas.
//

import SwiftUI

struct HeaderShortcutsView: View {
    var color: Color = SparkColors.lavender
    var hideMusic = false
    var hideReminders = false
    var hideCircles = false
    var onNavigate: (AppRoute) -> Void

    var body: some View {
        HStack(spacing: SparkSpacing.xs) {
            if !hideMusic {
                shortcutButton(
                    systemImage: "music.note",
                    label: "Music",
                    route: .music
                )
            }
            if !hideReminders {
                shortcutButton(
                    systemImage: "bell.badge.fill",
                    label: "Reminders",
                    route: .reminders
                )
            }
            if !hideCircles {
                shortcutButton(
                    systemImage: "person.3.fill",
                    label: "Spark Circle",
                    route: .circle
                )
            }
        }
    }

    private func shortcutButton(systemImage: String, label: String, route: AppRoute) -> some View {
        Button {
            SparkHaptics.lightImpact()
            onNavigate(route)
        } label: {
            Image(systemName: systemImage)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(color)
                .frame(width: 44, height: 44)
                .background(SparkColors.card)
                .clipShape(Capsule())
                .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }
}

#Preview {
    HeaderShortcutsView(onNavigate: { _ in })
        .padding()
        .background(SparkColors.cream)
}
