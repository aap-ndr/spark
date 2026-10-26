//
//  MainTabView.swift
//  Spark
//
//  Purpose:
//  Primary tab bar shell for the authenticated app.
//
//  Responsibilities:
//  • Hosts Home, Quests, Focus, Feelings, and Me tabs.
//  • Applies tab styling and shared environment wiring.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum SparkTab: Int, CaseIterable, Identifiable {
    case home
    case quests
    case focus
    case feelings
    case me

    var id: Int { rawValue }

    /// Tab bar labels shown in the main interface.
    var title: String {
        switch self {
        case .home: return "Home"
        case .quests: return "Quests"
        case .focus: return "Focus"
        case .feelings: return "Feelings"
        case .me: return "Me"
        }
    }

    /// SF Symbol names for each tab icon.
    /// Home, ListChecks, Timer, Smile, User
    var symbol: String {
        switch self {
        case .home: return "house.fill"
        case .quests: return "checklist"
        case .focus: return "timer"
        case .feelings: return "face.smiling"
        case .me: return "person.fill"
        }
    }
}

struct MainTabView: View {
    @Environment(AppNavigationCoordinator.self) private var navigation
    @Environment(\.sparkSkin) private var skin

    // TODO(AppTour): Auto-present `AppTour` after onboarding when a profile exists and
    // `hasSeenTour` is false. Deferred to a later phase.

    var body: some View {
        @Bindable var navigation = navigation

        ZStack(alignment: .bottom) {
            TabView(selection: $navigation.selectedTab) {
            HomeNavigationView()
                .tabItem {
                    Label(SparkTab.home.title, systemImage: SparkTab.home.symbol)
                }
                .tag(SparkTab.home)

            QuestsView()
                .tabItem {
                    Label(SparkTab.quests.title, systemImage: SparkTab.quests.symbol)
                }
                .tag(SparkTab.quests)

            FocusView()
                .tabItem {
                    Label {
                        Text(SparkTab.focus.title)
                    } icon: {
                        FocusTabIconView()
                    }
                }
                .tag(SparkTab.focus)

            FeelingsView()
                .tabItem {
                    Label(SparkTab.feelings.title, systemImage: SparkTab.feelings.symbol)
                }
                .tag(SparkTab.feelings)

            tabRoot(for: .me) {
                MeView()
            }
            }
            .tint(skin.accent)

            MiniPlayerBar()
            MusicPlaybackBridge()
        }
        .onAppear {
            SparkTabBarAppearance.apply(accent: skin.accent)
        }
        .onChange(of: skin.id) { _, _ in
            SparkTabBarAppearance.apply(accent: skin.accent)
        }
    }

    @ViewBuilder
    private func tabRoot<Content: View>(
        for tab: SparkTab,
        @ViewBuilder content: () -> Content
    ) -> some View {
        NavigationStack {
            content()
        }
        .tabItem {
            Label(tab.title, systemImage: tab.symbol)
        }
        .tag(tab)
    }
}

enum SparkTabBarAppearance {
    static func apply(accent: Color) {
        #if canImport(UIKit)
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(SparkColors.white)
        appearance.shadowColor = UIColor(accent).withAlphaComponent(0.08)

        let normalAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(SparkColors.inkSoft),
            .font: tabLabelFont(),
        ]
        let selectedAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor(accent),
            .font: tabLabelFont(),
        ]

        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(SparkColors.inkSoft)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(accent)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        #endif
    }

    #if canImport(UIKit)
    private static func tabLabelFont() -> UIFont {
        UIFont.systemFont(ofSize: 11, weight: .semibold)
    }
    #endif
}

#Preview {
    MainTabView()
        .environment(CircleStore())
        .environment(AppNavigationCoordinator())
        .environment(AppProfileStore())
        .environment(QuestStore())
        .environment(FocusStore())
        .environment(DatesStore())
        .environment(CycleStore())
        .environment(FeelingsStore())
        .environment(MusicStore())
        .environment(NotifSettingsStore())
        .environment(TimerStore())
        .environment(ThingsStore())
        .environment(RemindersStore())
        .environment(ReminderCategoriesStore())
        .environment(SavedOpportunitiesStore())
        .environment(SkinStore())
        .environment(\.sparkSkin, SparkSkinCatalog.defaultSkin)
        .preferredColorScheme(.light)
}
