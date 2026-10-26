//
//  TabPlaceholderScreen.swift
//  Spark
//
//  Purpose:
//  Generic placeholder screen layout for unfinished destinations.
//
//  Responsibilities:
//  • Provides consistent placeholder chrome and messaging.
//

import SwiftUI

struct TabPlaceholderScreen: View {
    let title: String
    let message: String
    var detail: String?

    var body: some View {
        ZStack {
            SparkColors.cream.ignoresSafeArea()

            VStack(spacing: SparkSpacing.sm) {
                Text(title)
                    .sparkSectionTitle()
                Text(message)
                    .sparkSupportive()
                    .multilineTextAlignment(.center)

                if let detail {
                    Text(detail)
                        .font(SparkTypography.caption())
                        .foregroundStyle(SparkColors.inkSoft)
                        .multilineTextAlignment(.center)
                        .padding(.top, SparkSpacing.xs)
                }
            }
            .padding(.horizontal, SparkSpacing.screenHorizontal)
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        TabPlaceholderScreen(
            title: "Home",
            message: "Home screen coming next.",
            detail: "Bella · nova"
        )
    }
}
