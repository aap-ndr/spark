//
//  QuestShareSection.swift
//  Spark
//
//  Purpose:
//  Quest circle sharing section.
//
//  Responsibilities:
//  • Selects circles to share quest progress with.
//

import SwiftUI

struct QuestShareSection: View {
    let quest: Quest
    let circles: [SparkCircle]
    let onToggleCircle: (String, String) -> Void

    @State private var pickerOpen = false

    private var sharedIDs: [String] {
        quest.circleIds ?? []
    }

    private var sharedCircles: [SparkCircle] {
        circles.filter { sharedIDs.contains($0.id) }
    }

    private var isShared: Bool {
        !sharedCircles.isEmpty
    }

    var body: some View {
        Group {
            if circles.isEmpty {
                Text("Create a Spark Circle to share quests 🌸")
                    .font(SparkTypography.caption())
                    .foregroundStyle(SparkColors.inkSoft)
                    .lineSpacing(5)
            } else {
                shareContent
            }
        }
    }

    private var shareContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                SparkHaptics.lightImpact()
                pickerOpen.toggle()
            } label: {
                HStack(spacing: SparkSpacing.xs) {
                    Image(systemName: "person.3.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isShared ? SparkColors.lavender : SparkColors.inkSoft)
                    Text(shareLabel)
                        .font(SparkTypography.accentLink())
                        .foregroundStyle(isShared ? SparkColors.lavender : SparkColors.inkSoft)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(SparkColors.lavenderSoft)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .frame(minHeight: 44, alignment: .leading)
            .accessibilityLabel(isShared ? "Manage shared circles" : "Share with a circle")

            if pickerOpen {
                VStack(alignment: .leading, spacing: SparkSpacing.xs) {
                    Text("Pick any circles to share this quest with 🌸")
                        .font(SparkTypography.caption())
                        .foregroundStyle(SparkColors.inkSoft)
                        .lineSpacing(5)
                        .padding(.top, 10)

                    ForEach(circles) { circle in
                        let selected = sharedIDs.contains(circle.id)
                        Button {
                            SparkHaptics.lightImpact()
                            onToggleCircle(quest.id, circle.id)
                        } label: {
                            HStack(spacing: 10) {
                                Text(circle.emoji)
                                    .font(.system(size: 20))
                                Text(circle.name)
                                    .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                                    .foregroundStyle(SparkColors.ink)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if selected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(SparkColors.lavender)
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, SparkSpacing.sm)
                            .background(selected ? SparkColors.lavenderSoft : SparkColors.cream)
                            .overlay(
                                RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                                    .stroke(selected ? SparkColors.lavender : Color.clear, lineWidth: 2)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .frame(minHeight: 44)
                        .accessibilityLabel("\(circle.name), \(selected ? "selected" : "not selected")")
                    }

                    Button {
                        SparkHaptics.lightImpact()
                        pickerOpen = false
                    } label: {
                        HStack(spacing: SparkSpacing.xs) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(SparkColors.inkSoft)
                            Text("Done")
                                .font(SparkTypography.accentLink())
                                .foregroundStyle(SparkColors.inkSoft)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .padding(.horizontal, SparkSpacing.sm)
                        .background(SparkColors.lavenderSoft)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .frame(minHeight: 44)
                    .accessibilityLabel("Done sharing selection")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: pickerOpen ? .infinity : nil, alignment: .leading)
    }

    private var shareLabel: String {
        if !isShared {
            return "Share with a circle"
        }
        if sharedCircles.count == 1, let circle = sharedCircles.first {
            return "\(circle.emoji) Shared with \(circle.name)"
        }
        let emojis = sharedCircles.map(\.emoji).joined()
        return "\(emojis) Shared with \(sharedCircles.count) circles"
    }
}

#Preview {
    QuestShareSection(
        quest: Quest(
            id: "1",
            title: "Test",
            emoji: "✨",
            color: "lavender",
            steps: [],
            createdAt: 0,
            remindAt: nil,
            notificationId: nil,
            circleIds: nil
        ),
        circles: [
            SparkCircle(
                id: "c1",
                name: "Sunshine Squad",
                emoji: "🌻",
                inviteCode: "ABC123",
                members: [],
                createdAt: 0
            ),
        ],
        onToggleCircle: { _, _ in }
    )
    .padding()
    .background(SparkColors.cream)
}
