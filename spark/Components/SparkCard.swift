//
//  SparkCard.swift
//  Spark
//
//  Purpose:
//  Shared card container with optional background color.
//
//  Responsibilities:
//  • Provides consistent padding, radius, and shadow for grouped content.
//

import SwiftUI

struct SparkCard<Content: View>: View {
    private let padding: CGFloat
    private let backgroundColor: Color
    @ViewBuilder private var content: () -> Content

    init(
        padding: CGFloat = SparkSpacing.cardPadding,
        backgroundColor: Color = SparkColors.card,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.padding = padding
        self.backgroundColor = backgroundColor
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(padding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
        .sparkSoftShadow()
    }
}

#Preview {
    SparkCard {
        Text("Spark Card")
            .sparkSectionTitle()
    }
    .padding()
    .background(SparkColors.cream)
}
