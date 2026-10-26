//
//  SparkAccentLink.swift
//  Spark
//
//  Purpose:
//  Reusable accent link text styling.
//
//  Responsibilities:
//  • Applies lavender link typography for secondary actions.
//

import SwiftUI

/// Accent link style used for secondary actions and "See all" controls.
struct SparkAccentLink: View {
    let title: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .sparkAccentLink()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

#Preview {
    SparkAccentLink(title: "See all") {}
        .padding()
        .background(SparkColors.cream)
}
