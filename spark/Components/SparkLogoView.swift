//
//  SparkLogoView.swift
//  Spark
//
//  Purpose:
//  Spark logo mark with optional interactive animation.
//
//  Responsibilities:
//  • Renders the brand logo at configurable sizes.
//

import SwiftUI

struct SparkLogoView: View {
    var size: CGFloat = 64
    var isInteractive: Bool = false
    var onTap: (() -> Void)?

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var breathe = false
    @State private var tapScale: CGFloat = 1
    @State private var tapRotation: Double = 0
    @State private var sparkleProgress: CGFloat = 0

    private static let rainbowColors: [Color] = [
        Color(sparkHex: 0xFF2E86),
        Color(sparkHex: 0xFF3D8F),
        Color(sparkHex: 0xFF5FA2),
        Color(sparkHex: 0xFF8A3D),
        Color(sparkHex: 0xFFD24D),
        Color(sparkHex: 0x4ECB7B),
        Color(sparkHex: 0x3E9BFF),
        Color(sparkHex: 0x9B4BE6),
        Color(sparkHex: 0xB02BE6),
        Color(sparkHex: 0xC72BDC),
        Color(sparkHex: 0xE03BC0),
    ]

    private static let satelliteSparkles: [(x: CGFloat, y: CGFloat, scale: CGFloat, color: Color)] = [
        (0.02, 0.08, 0.16, Color(sparkHex: 0xFFD34E)),
        (0.82, 0.0, 0.13, Color(sparkHex: 0xFF8A00)),
        (0.9, 0.7, 0.15, Color(sparkHex: 0x2E9BFF)),
        (-0.05, 0.72, 0.12, Color(sparkHex: 0x8A46E6)),
    ]

    var body: some View {
        Group {
            if isInteractive || onTap != nil {
                Button(action: handleTap) {
                    logoContent
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Spark logo")
            } else {
                logoContent
                    .accessibilityLabel("Spark")
            }
        }
        .onAppear {
            startBreathingIfNeeded()
        }
    }

    private var logoContent: some View {
        ZStack {
            ForEach(Array(Self.satelliteSparkles.enumerated()), id: \.offset) { _, sparkle in
                Circle()
                    .fill(sparkle.color)
                    .frame(width: size * sparkle.scale, height: size * sparkle.scale)
                    .offset(x: sparkle.x * size, y: sparkle.y * size)
                    .opacity(sparkleProgress)
                    .scaleEffect(sparkleProgress)
            }

            ZStack {
                SparkStarShape()
                    .fill(rainbowGradient)
                    .opacity(0.55)
                    .blur(radius: size * 0.03)

                SparkStarShape()
                    .fill(rainbowGradient)

                SparkAccentStarShape()
                    .fill(rainbowGradient)
                    .opacity(0.92)
                    .frame(width: size * 0.22, height: size * 0.22)
                    .offset(x: size * 0.24, y: -size * 0.28)
            }
            .scaleEffect(tapScale * (breathe ? 1.04 : 1))
            .rotationEffect(.degrees(tapRotation))
            .offset(y: breathe ? -size * 0.03 : 0)
        }
        .frame(width: size, height: size)
        .animation(reduceMotion ? nil : .easeInOut(duration: 2.6).repeatForever(autoreverses: true), value: breathe)
        .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.62), value: tapScale)
        .animation(reduceMotion ? nil : .spring(response: 0.35, dampingFraction: 0.62), value: tapRotation)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.18), value: sparkleProgress)
    }

    private var rainbowGradient: LinearGradient {
        LinearGradient(
            colors: Self.rainbowColors,
            startPoint: UnitPoint(x: 0.08, y: 0.12),
            endPoint: UnitPoint(x: 0.92, y: 0.88)
        )
    }

    private func startBreathingIfNeeded() {
        guard !reduceMotion else { return }
        breathe = true
    }

    private func handleTap() {
        SparkHaptics.mediumImpact()
        onTap?()

        guard !reduceMotion else { return }

        tapScale = 1.18
        tapRotation = -9
        sparkleProgress = 1

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            tapScale = 1
            tapRotation = 7
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            tapRotation = 0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.42) {
            sparkleProgress = 0
        }
    }
}

private struct SparkStarShape: Shape {
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

private struct SparkAccentStarShape: Shape {
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
    SparkLogoView(size: 96, isInteractive: true)
        .padding()
        .background(SparkColors.cream)
}
