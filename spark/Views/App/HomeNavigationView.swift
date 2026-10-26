//
//  HomeNavigationView.swift
//  Spark
//
//  Purpose:
//  Navigation stack wrapper for the Home tab.
//
//  Responsibilities:
//  • Registers home-stack destinations and hosts HomeView.
//

import SwiftUI

/// Owns the Home tab NavigationStack and all Home-stack destination registrations.
struct HomeNavigationView: View {
    @Environment(AppNavigationCoordinator.self) private var navigation

    var body: some View {
        @Bindable var navigation = navigation

        NavigationStack(path: $navigation.homePath) {
            HomeView()
                .navigationDestination(for: AppRoute.self) { route in
                    AppRouteDestination(route: route)
                }
        }
    }
}

#Preview {
    HomeNavigationView()
        .environment(AppNavigationCoordinator())
        .environment(AppProfileStore())
        .environment(QuestStore())
        .environment(FocusStore())
        .environment(DatesStore())
        .environment(CycleStore())
        .environment(CircleStore())
        .environment(\.sparkSkin, SparkSkinCatalog.defaultSkin)
}
