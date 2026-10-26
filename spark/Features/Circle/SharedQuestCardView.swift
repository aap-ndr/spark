//
//  SharedQuestCardView.swift
//  Spark
//
//  Purpose:
//  Compact shared quest card for circle views.
//
//  Responsibilities:
//  • Summarizes quest progress shared with a circle.
//

import SwiftUI

struct SharedQuestCardView: View {
    let quest: Quest
    let action: () -> Void

    private var done: Int {
        quest.steps.filter(\.done).count
    }

    private var total: Int {
        quest.steps.count
    }

    private var progress: Double {
        guard total > 0 else { return 0 }
        return Double(done) / Double(total)
    }

    var body: some View {
        SparkPressableCard(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: SparkSpacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                            .fill(SparkTheme.gradient(forKey: quest.color))
                            .frame(width: 44, height: 44)
                        Text(quest.emoji)
                            .font(.system(size: 22))
                            .accessibilityHidden(true)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text(quest.title)
                            .font(SparkTypography.font(.displayBold, size: 16, relativeTo: .body))
                            .foregroundStyle(SparkColors.ink)
                            .lineLimit(1)
                        Text("\(done) of \(total) steps done")
                            .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                            .foregroundStyle(SparkColors.inkSoft)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(SparkColors.lavenderSoft)
                        Capsule()
                            .fill(SparkTheme.gradient(forKey: quest.color))
                            .frame(width: max(0, geometry.size.width * progress))
                    }
                }
                .frame(height: 8)
                .padding(.top, SparkSpacing.sm)
            }
        }
        .accessibilityLabel("\(quest.title), \(done) of \(total) steps done")
    }
}
