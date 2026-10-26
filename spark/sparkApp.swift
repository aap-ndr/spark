//
//  sparkApp.swift
//  Spark
//
//  Purpose:
//  Application entry point and global dependency injection.
//
//  Responsibilities:
//  • Bootstraps observable stores and navigation coordinator.
//  • Hosts the root ContentView in a WindowGroup.
//  • Applies the active app skin and light color scheme.
//

import SwiftUI

@main
struct sparkApp: App {
    @State private var profileStore = AppProfileStore()
    @State private var questStore = QuestStore()
    @State private var focusStore = FocusStore()
    @State private var datesStore = DatesStore()
    @State private var cycleStore = CycleStore()
    @State private var circleStore = CircleStore()
    @State private var feelingsStore = FeelingsStore()
    @State private var musicStore = MusicStore()
    @State private var notifSettingsStore = NotifSettingsStore()
    @State private var timerStore = TimerStore()
    @State private var thingsStore = ThingsStore()
    @State private var remindersStore = RemindersStore()
    @State private var reminderCategoriesStore = ReminderCategoriesStore()
    @State private var savedOpportunitiesStore = SavedOpportunitiesStore()
    @State private var skinStore = SkinStore()
    @State private var navigation = AppNavigationCoordinator()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(profileStore)
                .environment(questStore)
                .environment(focusStore)
                .environment(datesStore)
                .environment(cycleStore)
                .environment(circleStore)
                .environment(feelingsStore)
                .environment(musicStore)
                .environment(notifSettingsStore)
                .environment(timerStore)
                .environment(thingsStore)
                .environment(remindersStore)
                .environment(reminderCategoriesStore)
                .environment(savedOpportunitiesStore)
                .environment(skinStore)
                .environment(navigation)
                .environment(\.sparkSkin, skinStore.activeSkin)
                .preferredColorScheme(.light)
        }
    }
}
