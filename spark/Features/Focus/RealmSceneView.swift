//
//  RealmSceneView.swift
//  Spark
//
//  Purpose:
//  Focus realm scene with timer ring and ambient visuals.
//
//  Responsibilities:
//  • Renders the active realm background, timer, and controls.
//

import SwiftUI

struct RealmSceneView<Content: View>: View {
    let realm: FocusRealm
    let height: CGFloat
    @ViewBuilder let content: () -> Content

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var orbPhase: CGFloat = 0

    private let particleCount = 14

    var body: some View {
        ZStack {
            LinearGradient(
                colors: realm.backdrop,
                startPoint: UnitPoint(x: 0.1, y: 0),
                endPoint: UnitPoint(x: 0.9, y: 1)
            )

            GeometryReader { proxy in
                ForEach(0..<particleCount, id: \.self) { index in
                    FocusParticleView(
                        kind: realm.particleKind,
                        glyph: realm.particleGlyphs[index % realm.particleGlyphs.count],
                        index: index,
                        width: proxy.size.width,
                        height: proxy.size.height,
                        reduceMotion: reduceMotion
                    )
                }
            }

            GeometryReader { proxy in
                let orbSize = proxy.size.width * 0.7
                Circle()
                    .fill(Color.white.opacity(0.25))
                    .frame(width: orbSize, height: orbSize)
                    .position(x: proxy.size.width * 0.5, y: proxy.size.height * 0.5)
                    .scaleEffect(reduceMotion ? 1 : 0.95 + orbPhase * 0.13)
                    .opacity(reduceMotion ? 0.45 : 0.35 + orbPhase * 0.25)
            }

            Rectangle()
                .fill(realm.tint)
                .allowsHitTesting(false)

            content()
                .zIndex(2)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.xl, style: .continuous))
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 9).repeatForever(autoreverses: true)) {
                orbPhase = 1
            }
        }
    }
}

private struct FocusParticleView: View {
    let kind: FocusParticleKind
    let glyph: String
    let index: Int
    let width: CGFloat
    let height: CGFloat
    let reduceMotion: Bool

    @State private var progress: CGFloat = 0

    private var seedX: CGFloat { pseudoRandom(index, salt: 1) }
    private var seedY: CGFloat { pseudoRandom(index, salt: 2) }
    private var baseLeft: CGFloat { seedX * max(width - 40, 1) }
    private var size: CGFloat { 12 + CGFloat(index % 4) * 5 }
    private var duration: Double { 7 + Double(index % 5) * 1.6 }
    private var delay: Double { Double(index % 6) * 0.7 }
    private var drift: CGFloat { (seedY - 0.5) * 60 }

    var body: some View {
        Text(glyph)
            .font(.system(size: size))
            .foregroundStyle(Color.white.opacity(0.9))
            .position(x: xPosition, y: yPosition)
            .opacity(opacity)
            .onAppear {
                guard !reduceMotion else {
                    progress = 0.5
                    return
                }
                withAnimation(.easeInOut(duration: duration).delay(delay).repeatForever(autoreverses: false)) {
                    progress = 1
                }
            }
    }

    private var xPosition: CGFloat {
        switch kind {
        case .bubble, .mote:
            return baseLeft + sin(progress * .pi * 2) * 18 + drift * progress
        case .leaf:
            return baseLeft + sin(progress * .pi * 3) * 26 + drift
        case .cloud:
            return interpolate(progress, from: -70, to: width + 30)
        case .star:
            return baseLeft
        }
    }

    private var yPosition: CGFloat {
        switch kind {
        case .bubble, .mote:
            return interpolate(progress, from: height * 0.9, to: height * 0.05)
        case .leaf:
            return interpolate(progress, from: -30, to: height * 0.95)
        case .cloud:
            return seedY * height * 0.7 + 20
        case .star:
            return seedY * height * 0.85 + 10
        }
    }

    private var opacity: Double {
        if reduceMotion { return kind == .star ? 0.7 : 0.55 }
        switch kind {
        case .star:
            let twinkle = sin(progress * .pi * 2) * 0.4 + 0.6
            return twinkle
        case .bubble, .mote, .leaf, .cloud:
            if progress < 0.12 { return Double(progress / 0.12) * 0.85 }
            if progress > 0.85 { return Double((1 - progress) / 0.15) * 0.85 }
            return 0.85
        }
    }

    private func interpolate(_ value: CGFloat, from: CGFloat, to: CGFloat) -> CGFloat {
        from + (to - from) * value
    }

    private func pseudoRandom(_ index: Int, salt: Int) -> CGFloat {
        let value = sin(Double(index) * 127.1 + Double(salt) * 311.7) * 43758.5453
        return CGFloat(value - floor(value))
    }
}

struct FocusTimerRingView: View {
    let realm: FocusRealm
    let remaining: Int
    let progress: Double
    let statusLabel: String

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.28), lineWidth: FocusContent.stroke)
                .padding(FocusContent.stroke / 2)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    realm.ringColor,
                    style: StrokeStyle(lineWidth: FocusContent.stroke, lineCap: .round)
                )
                .padding(FocusContent.stroke / 2)
                .rotationEffect(.degrees(-90))

            VStack(spacing: 6) {
                Text(realm.emoji)
                    .font(.system(size: 42))
                Text(FocusContent.formatTime(seconds: remaining))
                    .font(SparkTypography.font(.displayBold, size: 48, relativeTo: .largeTitle))
                    .foregroundStyle(SparkColors.white)
                    .monospacedDigit()
                    .accessibilityLabel("Time remaining \(FocusContent.formatTime(seconds: remaining))")
                Text(statusLabel)
                    .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                    .foregroundStyle(Color.white.opacity(0.9))
            }
        }
        .frame(width: FocusContent.ringSize, height: FocusContent.ringSize)
    }
}

#if canImport(UIKit)
import UIKit
#endif

#Preview {
    RealmSceneView(realm: FocusContent.realms[0], height: 430) {
        FocusTimerRingView(realm: FocusContent.realms[0], remaining: 900, progress: 0.2, statusLabel: "ready when you are")
    }
    .padding()
}
