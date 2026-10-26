//
//  AppRouteDestination.swift
//  Spark
//
//  Purpose:
//  Route-to-view factory for stack navigation destinations.
//
//  Responsibilities:
//  • Maps AppRoute values to their destination screens.
//

import SwiftUI

struct AppRouteDestination: View {
    let route: AppRoute

    var body: some View {
        switch route {
        case .cycle:
            CycleView()
        case .music:
            MusicView()
        case .dates:
            DatesView()
        case .timer:
            TimerView()
        case .findThings:
            FindThingsView()
        case .reminders:
            RemindersView()
        case .learn:
            LearnView()
        case .circle:
            CircleView()
        case .opportunities:
            OpportunitiesView()
        default:
            RoutePlaceholderView(route: route)
        }
    }
}
