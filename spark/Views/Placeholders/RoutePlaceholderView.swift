//
//  RoutePlaceholderView.swift
//  Spark
//
//  Purpose:
//  Fallback destination for routes without a dedicated screen yet.
//
//  Responsibilities:
//  • Shows a lightweight placeholder until a route is fully implemented.
//

import SwiftUI

struct RoutePlaceholderView: View {
    let route: AppRoute

    var body: some View {
        TabPlaceholderScreen(
            title: route.placeholderTitle,
            message: "\(route.placeholderTitle) screen coming next."
        )
    }
}

#Preview {
    NavigationStack {
        RoutePlaceholderView(route: .learn)
    }
}
