//
//  SparkleBadge.swift
//  Spark
//
//  Purpose:
//  Sparkle icon badge used in stats and rewards UI.
//
//  Responsibilities:
//  • Renders the spark reward glyph at configurable sizes.
//

import SwiftUI

struct SparkleBadge: View {
    var size: CGFloat = 20
    var color: Color = SparkColors.yellow

    var body: some View {
        Image(systemName: "sparkles")
            .font(.system(size: size, weight: .semibold))
            .symbolRenderingMode(.palette)
            .foregroundStyle(color, color.opacity(0.85))
            .accessibilityLabel("Sparkle badge")
    }
}

struct SparkMarkView: View {
    var size: CGFloat = 26
    var gradient: LinearGradient = LinearGradient(
        colors: [SparkColors.pink, SparkColors.lavender],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            SparkMarkStarShape()
                .fill(gradient)

            SparkMarkAccentShape()
                .fill(gradient)
                .opacity(0.85)
                .frame(width: size * 0.28, height: size * 0.28)
                .offset(x: size * 0.22, y: -size * 0.24)
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Spark mark")
    }
}

private struct SparkMarkStarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let scaleX = rect.width / 24
        let scaleY = rect.height / 24

        var path = Path()
        path.move(to: CGPoint(x: 12 * scaleX, y: 1.5 * scaleY))
        path.addCurve(
            to: CGPoint(x: 20.5 * scaleX, y: 12 * scaleY),
            control1: CGPoint(x: 12.5 * scaleX, y: 5.9 * scaleY),
            control2: CGPoint(x: 14.6 * scaleX, y: 8.1 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 12 * scaleX, y: 22.5 * scaleY),
            control1: CGPoint(x: 17.1 * scaleX, y: 15.9 * scaleY),
            control2: CGPoint(x: 15 * scaleX, y: 18.1 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 3.5 * scaleX, y: 12 * scaleY),
            control1: CGPoint(x: 9 * scaleX, y: 18.1 * scaleY),
            control2: CGPoint(x: 6.9 * scaleX, y: 15.9 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 12 * scaleX, y: 1.5 * scaleY),
            control1: CGPoint(x: 6.9 * scaleX, y: 8.1 * scaleY),
            control2: CGPoint(x: 9.4 * scaleX, y: 5.9 * scaleY)
        )
        path.closeSubpath()
        return path
    }
}

private struct SparkMarkAccentShape: Shape {
    func path(in rect: CGRect) -> Path {
        let scaleX = rect.width / 4.5
        let scaleY = rect.height / 5.4

        var path = Path()
        path.move(to: CGPoint(x: 2.25 * scaleX, y: 0 * scaleY))
        path.addCurve(
            to: CGPoint(x: 4.5 * scaleX, y: 2.7 * scaleY),
            control1: CGPoint(x: 2.43 * scaleX, y: 1.35 * scaleY),
            control2: CGPoint(x: 3.05 * scaleX, y: 1.98 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 2.25 * scaleX, y: 5.4 * scaleY),
            control1: CGPoint(x: 3.7 * scaleX, y: 3.42 * scaleY),
            control2: CGPoint(x: 3.08 * scaleX, y: 4.05 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 0 * scaleX, y: 2.7 * scaleY),
            control1: CGPoint(x: 1.42 * scaleX, y: 4.05 * scaleY),
            control2: CGPoint(x: 0.8 * scaleX, y: 3.42 * scaleY)
        )
        path.addCurve(
            to: CGPoint(x: 2.25 * scaleX, y: 0 * scaleY),
            control1: CGPoint(x: 1.42 * scaleX, y: 1.35 * scaleY),
            control2: CGPoint(x: 1.8 * scaleX, y: 0.72 * scaleY)
        )
        path.closeSubpath()
        return path
    }
}

#Preview {
    HStack(spacing: SparkSpacing.md) {
        SparkleBadge()
        SparkMarkView()
    }
    .padding()
    .background(SparkColors.cream)
}
