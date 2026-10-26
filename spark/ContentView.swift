//
//  ContentView.swift
//  Spark
//
//  Purpose:
//  Root view that gates between onboarding and the main tab interface.
//
//  Responsibilities:
//  • Observes profile hydration state from AppProfileStore.
//  • Routes new users to onboarding and returning users to MainTabView.
//  • Propagates the active skin through the environment.
//

import SwiftUI

/// Root view that routes between onboarding and the main tab interface.
struct ContentView: View {
    @Environment(AppProfileStore.self) private var profileStore
    @Environment(SkinStore.self) private var skinStore

    var body: some View {
        Group {
            if profileStore.hasProfile {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: profileStore.hasProfile)
        .environment(\.sparkSkin, skinStore.activeSkin)
    }
}

#Preview("Onboarding") {
    ContentView()
        .environment(AppProfileStore())
        .environment(SkinStore())
        .preferredColorScheme(.light)
}

#Preview("Main Tabs") {
    let store = AppProfileStore()
    store.createProfile(displayName: "Bella", avatarName: SparkAvatarCatalog.defaultOnboardingAvatarName)
    return ContentView()
        .environment(store)
        .environment(SkinStore())
        .preferredColorScheme(.light)
}
