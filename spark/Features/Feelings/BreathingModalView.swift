//
//  BreathingModalView.swift
//  Spark
//
//  Purpose:
//  Guided breathing exercise modal.
//
//  Responsibilities:
//  • Presents paced breathing animation and instructions.
//

import SwiftUI

private struct BreathPhase {
    let label: String
    let duration: TimeInterval
    let scale: CGFloat
}

private let breathPhases: [BreathPhase] = [
    BreathPhase(label: "Breathe in", duration: 4, scale: 1),
    BreathPhase(label: "Hold", duration: 4, scale: 1),
    BreathPhase(label: "Breathe out", duration: 4, scale: 0.45),
    BreathPhase(label: "Hold", duration: 4, scale: 0.45),
]

struct BreathingModalView: View {
    let onClose: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phaseIndex = 0
    @State private var circleScale: CGFloat = 0.45

    var body: some View {
        ZStack {
            SparkTheme.gradient(.ocean)
                .ignoresSafeArea()

            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(SparkColors.white)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.top, 60)
            .padding(.trailing, SparkSpacing.section)
            .accessibilityLabel("Close breathing exercise")

            VStack(spacing: 0) {
                Text(breathPhases[phaseIndex].label)
                    .font(SparkTypography.font(.displayBold, size: 30, relativeTo: .largeTitle))
                    .foregroundStyle(SparkColors.white)

                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 260, height: 260)
                        .scaleEffect(circleScale)

                    Text("🫧")
                        .font(.system(size: 44))
                        .scaleEffect(circleScale)
                }
                .padding(.top, 30)

                Text("Follow the circle. Slow and steady — you're safe right here. 🌊")
                    .font(SparkTypography.body())
                    .foregroundStyle(SparkColors.white.opacity(0.95))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
                    .padding(.top, 34)
            }
        }
        .task {
            phaseIndex = 0
            circleScale = 0.45
            await runBreathingLoop()
        }
    }

    private func runBreathingLoop() async {
        while !Task.isCancelled {
            for index in breathPhases.indices {
                guard !Task.isCancelled else { return }
                let phase = breathPhases[index]
                await MainActor.run {
                    phaseIndex = index
                    if reduceMotion {
                        circleScale = phase.scale
                    } else {
                        withAnimation(.easeInOut(duration: phase.duration)) {
                            circleScale = phase.scale
                        }
                    }
                }
                try? await Task.sleep(for: .seconds(phase.duration))
            }
        }
    }
}
