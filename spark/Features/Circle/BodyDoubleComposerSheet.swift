//
//  BodyDoubleComposerSheet.swift
//  Spark
//
//  Purpose:
//  Composer for scheduling body double sessions.
//
//  Responsibilities:
//  • Creates shared focus invitations for circle members.
//

import SwiftUI

struct BodyDoubleComposerSheet: View {
    let kind: BodyDoubleKind
    let onClose: () -> Void
    let onSubmit: (BodyDoubleKind, String?, String?, String?) -> Void

    @State private var task = ""
    @State private var when = ""
    @State private var note = ""
    @State private var showDiscardAlert = false

    private var hasUnsavedChanges: Bool {
        !task.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !when.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isNeed: Bool {
        kind == .need
    }

    private var accent: Color {
        isNeed ? SparkColors.pink : SparkColors.mint
    }

    private var canSubmit: Bool {
        if isNeed {
            return !task.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return !when.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(isNeed
                        ? "Ask a friend to keep you company while you work 💗"
                        : "Let your circle know when you can focus together 💪")
                        .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.inkSoft)
                        .lineSpacing(5)
                        .padding(.top, 4)

                    if isNeed {
                        sectionLabel("WHAT ARE YOU WORKING ON?")
                            .padding(.top, SparkSpacing.xl)
                        inputField("e.g. Math homework, tidy my room…", text: $task, maxLength: 80)
                            .padding(.top, SparkSpacing.xs)
                    }

                    sectionLabel(isNeed ? "WHEN (OPTIONAL)" : "WHEN")
                        .padding(.top, SparkSpacing.lg)

                    whenChips
                        .padding(.top, SparkSpacing.xs)
                        .padding(.bottom, 10)

                    inputField("or type a time, e.g. 7–8pm tonight", text: $when, maxLength: 40)

                    sectionLabel("NOTE (OPTIONAL)")
                        .padding(.top, SparkSpacing.lg)
                    multilineField(
                        isNeed ? "Anything that would help?" : "What kind of task or vibe?",
                        text: $note,
                        maxLength: 120
                    )
                    .padding(.top, SparkSpacing.xs)
                }
                .padding(.horizontal, SparkSpacing.section)
                .padding(.bottom, 44)
            }
            .scrollIndicators(.hidden)
            .background(SparkColors.cream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(isNeed ? "Need a body double" : "I'm free to focus")
                        .font(SparkTypography.font(.displayBold, size: 22, relativeTo: .title3))
                        .foregroundStyle(SparkColors.ink)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: requestClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(SparkColors.inkSoft)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(isNeed ? "Ask" : "Post") {
                        submit()
                    }
                    .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                    .disabled(!canSubmit)
                    .accessibilityLabel(isNeed ? "Ask for company" : "Post that I'm free")
                }
            }
        }
        .unsavedChangesDismissDisabled(hasUnsavedChanges)
        .discardChangesAlert(
            isPresented: $showDiscardAlert,
            message: UnsavedChangesGuard.formMessage("message"),
            onDiscard: onClose
        )
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func requestClose() {
        if hasUnsavedChanges {
            showDiscardAlert = true
        } else {
            onClose()
        }
    }

    private var whenChips: some View {
        FlowWrapLayout(spacing: SparkSpacing.xs) {
            ForEach(CircleContent.whenQuickPicks, id: \.self) { pick in
                let active = when == pick
                Button {
                    SparkHaptics.lightImpact()
                    when = pick
                } label: {
                    Text(pick)
                        .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                        .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(active ? accent : SparkColors.card)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityAddTraits(active ? .isSelected : [])
            }
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
            .foregroundStyle(SparkColors.ink)
    }

    private func inputField(_ placeholder: String, text: Binding<String>, maxLength: Int) -> some View {
        TextField(placeholder, text: text)
            .font(SparkTypography.body())
            .foregroundStyle(SparkColors.ink)
            .padding(15)
            .background(SparkColors.card)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
            .onChange(of: text.wrappedValue) { _, newValue in
                if newValue.count > maxLength {
                    text.wrappedValue = String(newValue.prefix(maxLength))
                }
            }
    }

    private func multilineField(_ placeholder: String, text: Binding<String>, maxLength: Int) -> some View {
        TextField(placeholder, text: text, axis: .vertical)
            .font(SparkTypography.body())
            .foregroundStyle(SparkColors.ink)
            .lineLimit(2...4)
            .padding(15)
            .frame(minHeight: 56, alignment: .topLeading)
            .background(SparkColors.card)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
            .onChange(of: text.wrappedValue) { _, newValue in
                if newValue.count > maxLength {
                    text.wrappedValue = String(newValue.prefix(maxLength))
                }
            }
    }

    private func submit() {
        onSubmit(
            kind,
            task.nilIfBlank,
            when.nilIfBlank,
            note.nilIfBlank
        )
        task = ""
        when = ""
        note = ""
    }
}

private extension String {
    var nilIfBlank: String? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

private struct FlowWrapLayout: Layout {
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for placement in result.placements {
            subviews[placement.index].place(
                at: CGPoint(x: bounds.minX + placement.origin.x, y: bounds.minY + placement.origin.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> Arrangement {
        let maxWidth = proposal.width ?? .infinity
        var origin = CGPoint.zero
        var rowHeight: CGFloat = 0
        var size = CGSize.zero
        var placements: [Placement] = []

        for index in subviews.indices {
            let dimension = subviews[index].sizeThatFits(.unspecified)
            if origin.x > 0, origin.x + dimension.width > maxWidth {
                origin.x = 0
                origin.y += rowHeight + spacing
                rowHeight = 0
            }
            placements.append(Placement(index: index, origin: origin))
            rowHeight = max(rowHeight, dimension.height)
            origin.x += dimension.width + spacing
            size.width = max(size.width, origin.x - spacing)
            size.height = max(size.height, origin.y + rowHeight)
        }

        return Arrangement(size: size, placements: placements)
    }

    private struct Placement {
        let index: Int
        let origin: CGPoint
    }

    private struct Arrangement {
        let size: CGSize
        let placements: [Placement]
    }
}
