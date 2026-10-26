//
//  AppNavigationCoordinator.swift
//  Spark
//
//  Purpose:
//  Shared navigation coordinator for tab and stack routing.
//
//  Responsibilities:
//  • Tracks selected tab and pending navigation intents.
//

import Foundation
import Observation

@Observable
final class AppNavigationCoordinator {
    var selectedTab: SparkTab = .home
    var homePath = NavigationPath()

    func navigate(to route: AppRoute) {
        if let tab = route.tab {
            selectedTab = tab
            return
        }
        homePath.append(route)
    }

    func navigateToCircleDetail(circleID: String) {
        homePath.append(CircleDestination(circleID: circleID))
    }
}

#if canImport(SwiftUI)
import SwiftUI
#endif
