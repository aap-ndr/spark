//
//  QuestCardView.swift
//  Spark
//
//  Purpose:
//  Expandable quest card with steps and actions.
//
//  Responsibilities:
//  • Renders quest progress, reminders, sharing, and reorder handle.
//

import SwiftUI

struct QuestCardView<DragHandle: View>: View {
    let quest: Quest
    let circles: [SparkCircle]
    @ViewBuilder let dragHandle: () -> DragHandle
    let onToggleStep: (String) -> Void
    let onDelete: () -> Void
    let onSetReminder: (String, Int64, String) -> Void
    let onClearReminder: (String) -> Void
    let onToggleCircle: (String, String) -> Void

    private var doneCount: Int {
        quest.steps.filter(\.done).count
    }

    private var totalCount: Int {
        quest.steps.count
    }

    private var isComplete: Bool {
        totalCount > 0 && doneCount == totalCount
    }

    private var progress: Double {
        guard totalCount > 0 else { return 0 }
        return Double(doneCount) / Double(totalCount)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            headerRow

            progressBar
                .padding(.top, 14)

            QuestChipRow {
                QuestReminderSection(
                    quest: quest,
                    onSetReminder: onSetReminder,
                    onClearReminder: onClearReminder
                )
                QuestShareSection(
                    quest: quest,
                    circles: circles,
                    onToggleCircle: onToggleCircle
                )
            }
            .padding(.top, 12)

            if isComplete {
                completionRibbon
                    .padding(.top, 14)
            }

            stepsList
                .padding(.top, 12)
        }
        .padding(SparkSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SparkColors.card)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
        .sparkSoftShadow()
    }

    private var headerRow: some View {
        HStack(spacing: 10) {
            dragHandle()

            ZStack {
                RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                    .fill(SparkTheme.gradient(forKey: quest.color))
                    .frame(width: 48, height: 48)
                Text(quest.emoji)
                    .font(.system(size: 24))
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(quest.title)
                    .font(SparkTypography.font(.displayBold, size: 17, relativeTo: .body))
                    .foregroundStyle(SparkColors.ink)
                Text("\(doneCount) of \(totalCount) steps done")
                    .font(SparkTypography.supportive())
                    .foregroundStyle(SparkColors.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundStyle(SparkColors.inkSoft)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Delete quest")
        }
    }

    private var progressBar: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(SparkColors.lavenderSoft)
                Capsule()
                    .fill(SparkTheme.gradient(forKey: quest.color))
                    .frame(width: max(0, proxy.size.width * progress))
            }
        }
        .frame(height: 10)
        .accessibilityLabel("Quest progress")
        .accessibilityValue("\(doneCount) of \(totalCount) steps done")
    }

    private var completionRibbon: some View {
        HStack(spacing: SparkSpacing.xs) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(SparkColors.white)
            Text("Quest complete! 🎉")
                .font(SparkTypography.font(.displayBold, size: 15, relativeTo: .body))
                .foregroundStyle(SparkColors.white)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SparkTheme.gradient(.dream))
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
    }

    private var stepsList: some View {
        VStack(spacing: 4) {
            ForEach(quest.steps) { step in
                Button {
                    onToggleStep(step.id)
                } label: {
                    HStack(spacing: 12) {
                        if step.done {
                            ZStack {
                                Circle()
                                    .fill(SparkColors.mint)
                                    .frame(width: 26, height: 26)
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(SparkColors.white)
                            }
                        } else {
                            Image(systemName: "circle")
                                .font(.system(size: 26, weight: .light))
                                .foregroundStyle(SparkColors.inkSoft)
                        }

                        Text(step.text)
                            .font(SparkTypography.body())
                            .foregroundStyle(step.done ? SparkColors.inkSoft : SparkColors.ink)
                            .strikethrough(step.done)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 10)
                    .frame(minHeight: 44, alignment: .leading)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(step.text)
                .accessibilityValue(step.done ? "Completed" : "Not completed")
                .accessibilityHint("Double tap to toggle")
            }
        }
    }
}

/// Horizontal wrapping row for step and circle chips inside a quest card.
private struct QuestChipRow<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        QuestFlowLayout(spacing: 8, rowSpacing: 8) {
            content()
        }
    }
}

private struct QuestFlowLayout: Layout {
    var spacing: CGFloat
    var rowSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var frames: [CGRect] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}

extension QuestCardView where DragHandle == EmptyView {
    init(
        quest: Quest,
        circles: [SparkCircle],
        onToggleStep: @escaping (String) -> Void,
        onDelete: @escaping () -> Void,
        onSetReminder: @escaping (String, Int64, String) -> Void,
        onClearReminder: @escaping (String) -> Void,
        onToggleCircle: @escaping (String, String) -> Void
    ) {
        self.init(
            quest: quest,
            circles: circles,
            dragHandle: { EmptyView() },
            onToggleStep: onToggleStep,
            onDelete: onDelete,
            onSetReminder: onSetReminder,
            onClearReminder: onClearReminder,
            onToggleCircle: onToggleCircle
        )
    }
}

#Preview {
    QuestCardView(
        quest: Quest(
            id: "1",
            title: "Get ready for school",
            emoji: "☀️",
            color: "sunrise",
            steps: [
                QuestStep(id: "s1", text: "Drink water", done: true, remindAt: nil, notificationId: nil),
                QuestStep(id: "s2", text: "Get dressed", done: false, remindAt: nil, notificationId: nil),
            ],
            createdAt: 0,
            remindAt: nil,
            notificationId: nil,
            circleIds: nil
        ),
        circles: [],
        onToggleStep: { _ in },
        onDelete: {},
        onSetReminder: { _, _, _ in },
        onClearReminder: { _ in },
        onToggleCircle: { _, _ in }
    )
    .padding()
    .background(SparkColors.cream)
}
