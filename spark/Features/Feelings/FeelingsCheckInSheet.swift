//
//  FeelingsCheckInSheet.swift
//  Spark
//
//  Purpose:
//  Feelings check-in composer sheet.
//
//  Responsibilities:
//  • Captures mood selections during a quick check-in flow.
//

import SwiftUI

struct FeelingsCheckInSheet: View {
    let feelings: [FeelingOption]
    let onClose: () -> Void
    let onSave: (Int, String?) -> Void

    @State private var intensity = 3
    @State private var note = ""
    @FocusState private var noteFocused: Bool

    private var label: String {
        feelings.map { "\($0.emoji) \($0.mood)" }.joined(separator: ", ")
    }

    var body: some View {
        VStack(spacing: 0) {
            if feelings.isEmpty {
                EmptyView()
            } else {
                VStack(spacing: 0) {
                    Text(feelings.map(\.emoji).joined(separator: " "))
                        .font(.system(size: 40))

                    Text("LOGGING")
                        .font(SparkTypography.font(.bodyExtra, size: 12, relativeTo: .caption))
                        .foregroundStyle(SparkColors.inkSoft)
                        .padding(.top, 10)

                    Text(label)
                        .font(SparkTypography.font(.displayBold, size: 19, relativeTo: .title3))
                        .foregroundStyle(SparkColors.ink)
                        .multilineTextAlignment(.center)
                        .lineSpacing(7)
                        .padding(.top, 4)

                    Text("HOW STRONG IS IT?")
                        .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.inkSoft)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 22)

                    HStack {
                        ForEach(1...5, id: \.self) { value in
                            intensityButton(value)
                        }
                    }
                    .padding(.top, 12)

                    HStack {
                        Text("a little")
                        Spacer()
                        Text("a lot")
                    }
                    .font(SparkTypography.caption())
                    .foregroundStyle(SparkColors.inkSoft)
                    .padding(.top, 8)

                    Text("WANT TO ADD A NOTE? (OPTIONAL)")
                        .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.inkSoft)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 22)

                    TextField("What's on your mind?", text: $note, axis: .vertical)
                        .font(SparkTypography.bodyLarge())
                        .foregroundStyle(SparkColors.ink)
                        .lineLimit(3...6)
                        .padding(.horizontal, SparkSpacing.md)
                        .padding(.vertical, 14)
                        .frame(minHeight: 70, alignment: .topLeading)
                        .background(SparkColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        .sparkSoftShadow()
                        .focused($noteFocused)
                        .padding(.top, 10)

                    SparkPrimaryButton(
                        label: feelings.count > 1 ? "Save check-ins" : "Save check-in",
                        gradient: SparkTheme.gradient(.pink),
                        iconSystemName: "checkmark",
                        action: {
                            SparkHaptics.successNotification()
                            onSave(intensity, note)
                        }
                    )
                    .padding(.top, 22)
                }
                .padding(.horizontal, SparkSpacing.section)
                .padding(.top, SparkSpacing.section)
                .padding(.bottom, 44)
            }
        }
        .frame(maxWidth: .infinity)
        .background(SparkColors.cream)
        .onAppear {
            intensity = 3
            note = ""
        }
    }

    private func intensityButton(_ value: Int) -> some View {
        let active = value <= intensity

        return Button {
            SparkHaptics.lightImpact()
            intensity = value
        } label: {
            Text("\(value)")
                .font(SparkTypography.font(.displayBold, size: 18, relativeTo: .body))
                .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
                .frame(width: 52, height: 52)
                .background(active ? SparkColors.pink : SparkColors.card)
                .clipShape(Circle())
                .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Intensity \(value) of 5")
        .accessibilityAddTraits(active && value == intensity ? .isSelected : [])
    }
}
