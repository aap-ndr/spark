//
//  SparkPrimaryButton.swift
//  Spark
//
//  Purpose:
//  Primary gradient button used for main calls to action.
//
//  Responsibilities:
//  • Supports icons, gradients, and disabled states.
//

import SwiftUI

struct SparkPrimaryButton: View {
    let label: String
    var gradient: LinearGradient = SparkTheme.primaryButtonGradient
    var isEnabled: Bool = true
    var isFullWidth: Bool = true
    var showsSparkleIcon: Bool = false
    var iconSystemName: String? = nil
    var iconFilled: Bool = false
    var action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false

    var body: some View {
        Button(action: handleTap) {
            HStack(spacing: SparkSpacing.xs) {
                if let iconSystemName {
                    Image(systemName: iconSystemName)
                        .font(.system(size: 18, weight: .semibold))
                        .symbolVariant(iconFilled ? .fill : .none)
                        .foregroundStyle(SparkColors.white)
                } else if showsSparkleIcon {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SparkColors.white)
                }

                Text(label)
                    .font(SparkTypography.button())
                    .foregroundStyle(SparkColors.white)
            }
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .padding(.vertical, SparkSpacing.buttonVertical)
                .padding(.horizontal, SparkSpacing.buttonHorizontal)
                .background(gradient)
                .clipShape(Capsule())
                .sparkSoftShadow()
                .opacity(isEnabled ? 1 : 0.5)
                .scaleEffect(isPressed && isEnabled && !reduceMotion ? 0.95 : 1)
                .animation(
                    reduceMotion ? nil : .spring(response: 0.28, dampingFraction: 0.75),
                    value: isPressed
                )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
        .accessibilityLabel(label)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    guard isEnabled else { return }
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }

    private func handleTap() {
        guard isEnabled else { return }
        SparkHaptics.mediumImpact()
        action()
    }
}

#Preview {
    SparkPrimaryButton(label: "Continue", action: {})
        .padding()
        .background(SparkColors.cream)
}
