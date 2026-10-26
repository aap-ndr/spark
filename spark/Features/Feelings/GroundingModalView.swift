//
//  GroundingModalView.swift
//  Spark
//
//  Purpose:
//  Grounding exercise modal for emotional regulation.
//
//  Responsibilities:
//  • Guides the user through a grounding prompt flow.
//

import SwiftUI

private struct GroundStep {
    let count: Int
    let sense: String
    let emoji: String
}

private let groundSteps: [GroundStep] = [
    GroundStep(count: 5, sense: "things you can SEE", emoji: "👀"),
    GroundStep(count: 4, sense: "things you can TOUCH", emoji: "✋"),
    GroundStep(count: 3, sense: "things you can HEAR", emoji: "👂"),
    GroundStep(count: 2, sense: "things you can SMELL", emoji: "👃"),
    GroundStep(count: 1, sense: "thing you can TASTE", emoji: "👅"),
]

struct GroundingModalView: View {
    let onClose: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var stepIndex = 0

    private var current: GroundStep { groundSteps[stepIndex] }
    private var isLast: Bool { stepIndex == groundSteps.count - 1 }

    var body: some View {
        ZStack {
            SparkTheme.gradient(.garden)
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
            .accessibilityLabel("Close grounding exercise")

            VStack(spacing: 0) {
                Text("GROUNDING · 5-4-3-2-1")
                    .font(SparkTypography.font(.bodyExtra, size: 14, relativeTo: .footnote))
                    .foregroundStyle(SparkColors.white.opacity(0.9))

                VStack(spacing: 4) {
                    Text(current.emoji)
                        .font(.system(size: 70))
                    Text("\(current.count)")
                        .font(SparkTypography.font(.displayBold, size: 80, relativeTo: .largeTitle))
                        .foregroundStyle(SparkColors.white)
                    Text(current.sense)
                        .font(SparkTypography.font(.displayBold, size: 22, relativeTo: .title2))
                        .foregroundStyle(SparkColors.white)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 26)
                .id(stepIndex)
                .transition(reduceMotion ? .opacity : .opacity.combined(with: .scale(scale: 0.98)))

                HStack(spacing: SparkSpacing.xs) {
                    ForEach(groundSteps.indices, id: \.self) { index in
                        Circle()
                            .fill(index == stepIndex ? SparkColors.white : Color.white.opacity(0.4))
                            .frame(width: 10, height: 10)
                    }
                }
                .padding(.top, 34)

                SparkPrimaryButton(
                    label: isLast ? "I feel more grounded 🌿" : "Next",
                    gradient: SparkTheme.gradient(.mint),
                    action: nextStep
                )
                .padding(.horizontal, SparkSpacing.xl)
                .padding(.top, 30)
            }
            .padding(.horizontal, 30)
        }
        .onAppear {
            stepIndex = 0
        }
    }

    private func nextStep() {
        SparkHaptics.lightImpact()
        if isLast {
            onClose()
        } else {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.35)) {
                stepIndex += 1
            }
        }
    }
}
