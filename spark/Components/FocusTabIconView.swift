//
//  FocusTabIconView.swift
//  Spark
//
//  Purpose:
//  Animated Focus tab icon reflecting timer running state.
//
//  Responsibilities:
//  • Shows running indicator styling when focus is active.
//

import SwiftUI

struct FocusTabIconView: View {
    @Environment(FocusStore.self) private var focusStore
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var color: Color = SparkColors.inkSoft
    var size: CGFloat = 23

    @State private var pulse = false

    private var isActive: Bool {
        focusStore.activeRealmName != nil
    }

    private let ringColor = Color(sparkHex: 0xFF2E86)

    var body: some View {
        ZStack {
            if isActive {
                Circle()
                    .stroke(ringColor, lineWidth: 3)
                    .frame(width: size + 11, height: size + 11)
                    .scaleEffect(reduceMotion ? 1 : (pulse ? 1.14 : 1))
                    .opacity(reduceMotion ? 0.85 : (pulse ? 1 : 0.7))
                    .shadow(color: ringColor.opacity(0.9), radius: 6)

                Circle()
                    .fill(ringColor)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().stroke(SparkColors.white, lineWidth: 1.5))
                    .offset(x: size * 0.35, y: -size * 0.35)
            }

            Image(systemName: "timer")
                .font(.system(size: size, weight: .semibold))
                .foregroundStyle(isActive ? ringColor : color)
        }
        .frame(width: size + 16, height: size + 16)
        .onAppear { startPulseIfNeeded() }
        .onChange(of: isActive) { _, active in
            if active {
                startPulseIfNeeded()
            } else {
                pulse = false
            }
        }
    }

    private func startPulseIfNeeded() {
        guard isActive, !reduceMotion else { return }
        withAnimation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true)) {
            pulse = true
        }
    }
}

#Preview {
    FocusTabIconView()
        .environment(FocusStore())
}
