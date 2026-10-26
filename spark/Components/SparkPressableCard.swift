//
//  SparkPressableCard.swift
//  Spark
//
//  Purpose:
//  Tappable card surface with press feedback.
//
//  Responsibilities:
//  • Combines card styling with subtle press animation.
//

import SwiftUI

struct SparkPressableCard<Content: View>: View {
    var backgroundColor: Color = SparkColors.card
    var padding: CGFloat = SparkSpacing.cardPadding
    var action: () -> Void
    @ViewBuilder var content: () -> Content

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                content()
            }
            .padding(padding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
            .sparkSoftShadow()
            .opacity(isPressed ? 0.8 : 1)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

#Preview {
    SparkPressableCard(action: {}) {
        Text("Pressable card")
            .sparkBody()
    }
    .padding()
    .background(SparkColors.cream)
}
