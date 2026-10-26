//
//  TimerRingView.swift
//  Spark
//
//  Purpose:
//  Circular timer ring used by focus and standalone timer.
//
//  Responsibilities:
//  • Displays remaining time with animated progress stroke.
//

import SwiftUI

enum TimerLayout {
    static let ringSize: CGFloat = 260
    static let stroke: CGFloat = 16

    static var radius: CGFloat {
        (ringSize - stroke) / 2
    }

    static var circumference: CGFloat {
        2 * .pi * radius
    }

    static func formatTime(seconds: Int) -> String {
        let clamped = max(0, seconds)
        let minutes = clamped / 60
        let secs = clamped % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

struct TimerRingView: View {
    let shownSeconds: Int
    let progress: Double
    let statusLabel: String

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Circle()
                .stroke(SparkColors.peachSoft, lineWidth: TimerLayout.stroke)
                .padding(TimerLayout.stroke / 2)

            Circle()
                .trim(from: 0, to: reduceMotion ? progress : progress)
                .stroke(
                    SparkColors.peach,
                    style: StrokeStyle(lineWidth: TimerLayout.stroke, lineCap: .round)
                )
                .padding(TimerLayout.stroke / 2)
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil : .linear(duration: 0.25), value: progress)

            VStack(spacing: 2) {
                Text(TimerLayout.formatTime(seconds: shownSeconds))
                    .font(SparkTypography.font(.displayBold, size: 58, relativeTo: .largeTitle))
                    .foregroundStyle(SparkColors.ink)
                    .monospacedDigit()
                    .minimumScaleFactor(0.7)
                    .lineLimit(1)
                    .accessibilityLabel("Timer \(TimerLayout.formatTime(seconds: shownSeconds))")

                Text(statusLabel)
                    .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .footnote))
                    .foregroundStyle(SparkColors.inkSoft)
                    .accessibilityHidden(true)
            }
        }
        .frame(width: TimerLayout.ringSize, height: TimerLayout.ringSize)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(TimerLayout.formatTime(seconds: shownSeconds)), \(statusLabel)")
    }
}
