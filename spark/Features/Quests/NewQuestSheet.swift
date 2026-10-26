//
//  NewQuestSheet.swift
//  Spark
//
//  Purpose:
//  Composer sheet for creating new quests.
//
//  Responsibilities:
//  • Collects title, emoji, steps, and circle sharing options.
//

import SwiftUI

struct NewQuestSheet: View {
    let circles: [SparkCircle]
    let onClose: () -> Void
    let onCreate: (String, String, [String], [String]) -> Void

    @State private var title = ""
    @State private var emoji = "✨"
    @State private var steps: [String] = []
    @State private var stepDraft = ""
    @State private var shareCircleIDs: [String] = []
    @State private var showDiscardAlert = false

    private var hasUnsavedChanges: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || emoji != "✨"
            || !steps.isEmpty
            || !stepDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !shareCircleIDs.isEmpty
    }

    private var canCreate: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !steps.isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    templatesSection
                    titleSection
                    emojiSection
                    stepsSection
                    shareSection
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.bottom, 40)
            }
            .background(SparkColors.cream)
            .navigationTitle("New Quest ✨")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: requestClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(SparkColors.inkSoft)
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel("Close new quest form")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createQuest()
                    }
                    .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                    .disabled(!canCreate)
                    .accessibilityLabel("Create quest")
                }
            }
        }
        .unsavedChangesDismissDisabled(hasUnsavedChanges)
        .discardChangesAlert(
            isPresented: $showDiscardAlert,
            message: UnsavedChangesGuard.formMessage("quest"),
            onDiscard: { reset(); onClose() }
        )
    }

    private var templatesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("QUICK START")
                .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 6)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(QuestContent.templates) { template in
                        Button {
                            applyTemplate(template)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(template.emoji)
                                    .font(.system(size: 22))
                                Text(template.title)
                                    .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                                    .foregroundStyle(SparkColors.ink)
                            }
                            .padding(.vertical, SparkSpacing.sm)
                            .padding(.horizontal, SparkSpacing.md)
                            .background(SparkColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                            .sparkSoftShadow()
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("Template: \(template.title)")
                    }
                }
                .padding(.top, 10)
            }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("WHAT'S THE GOAL?")
                .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 22)

            TextField("e.g. Finish my art project", text: $title)
                .font(SparkTypography.bodyLarge())
                .foregroundStyle(SparkColors.ink)
                .padding(.horizontal, SparkSpacing.md)
                .padding(.vertical, 14)
                .background(SparkColors.card)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .sparkSoftShadow()
                .padding(.top, 10)
        }
    }

    private var emojiSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("PICK AN EMOJI")
                .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 22)

            LazyVGrid(
                columns: Array(repeating: GridItem(.fixed(48), spacing: 10), count: 6),
                spacing: 10
            ) {
                ForEach(QuestContent.emojiChoices, id: \.self) { choice in
                    Button {
                        emoji = choice
                        SparkHaptics.lightImpact()
                    } label: {
                        Text(choice)
                            .font(.system(size: 24))
                            .frame(width: 48, height: 48)
                            .background(emoji == choice ? SparkColors.lavender : SparkColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                            .sparkSoftShadow()
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Emoji \(choice)")
                    .accessibilityAddTraits(emoji == choice ? .isSelected : [])
                }
            }
            .padding(.top, 10)
        }
    }

    private var stepsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("TINY STEPS")
                .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 22)

            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(spacing: 10) {
                    Image(systemName: "circle")
                        .font(.system(size: 20, weight: .regular))
                        .foregroundStyle(SparkColors.mint)
                    Text(step)
                        .font(SparkTypography.body())
                        .foregroundStyle(SparkColors.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Button {
                        steps.remove(at: index)
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(SparkColors.inkSoft)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Remove step")
                }
                .padding(.horizontal, 14)
                .padding(.vertical, SparkSpacing.sm)
                .background(SparkColors.mintSoft)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .padding(.top, 10)
            }

            HStack(spacing: 10) {
                TextField("Add a tiny step…", text: $stepDraft)
                    .font(SparkTypography.bodyLarge())
                    .foregroundStyle(SparkColors.ink)
                    .padding(.horizontal, SparkSpacing.md)
                    .padding(.vertical, 14)
                    .background(SparkColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                    .sparkSoftShadow()
                    .submitLabel(.done)
                    .onSubmit(addDraftStep)

                Button(action: addDraftStep) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(SparkColors.white)
                        .frame(width: 50, height: 50)
                        .background(SparkColors.mint)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        .sparkSoftShadow()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add step")
            }
            .padding(.top, 10)
        }
    }

    private var shareSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("SHARE WITH CIRCLES")
                .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 22)

            if circles.isEmpty {
                Text("Create a Spark Circle to share quests 🌸")
                    .font(SparkTypography.supportive())
                    .foregroundStyle(SparkColors.inkSoft)
                    .lineSpacing(6)
                    .padding(.top, SparkSpacing.xs)
            } else {
                FlowLayout(spacing: 10) {
                    ForEach(circles) { circle in
                        let selected = shareCircleIDs.contains(circle.id)
                        Button {
                            toggleShareCircle(circle.id)
                        } label: {
                            HStack(spacing: 6) {
                                Text(circle.emoji)
                                    .font(.system(size: 16))
                                Text(circle.name)
                                    .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                                    .foregroundStyle(selected ? SparkColors.white : SparkColors.inkSoft)
                                if selected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(SparkColors.white)
                                }
                            }
                            .padding(.vertical, 10)
                            .padding(.horizontal, 14)
                            .background(selected ? SparkColors.pink : SparkColors.card)
                            .clipShape(Capsule())
                            .sparkSoftShadow()
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(circle.name), \(selected ? "selected" : "not selected")")
                    }
                }
                .padding(.top, 10)
            }
        }
    }

    private func applyTemplate(_ template: QuestContent.QuestTemplate) {
        title = template.title
        emoji = template.emoji
        steps = template.steps
        SparkHaptics.lightImpact()
    }

    private func addDraftStep() {
        let trimmed = stepDraft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        steps.append(trimmed)
        stepDraft = ""
        SparkHaptics.lightImpact()
    }

    private func toggleShareCircle(_ id: String) {
        SparkHaptics.lightImpact()
        if shareCircleIDs.contains(id) {
            shareCircleIDs.removeAll { $0 == id }
        } else {
            shareCircleIDs.append(id)
        }
    }

    private func createQuest() {
        guard canCreate else { return }
        onCreate(title, emoji, steps, shareCircleIDs)
        reset()
    }

    private func requestClose() {
        if hasUnsavedChanges {
            showDiscardAlert = true
        } else {
            onClose()
        }
    }

    private func reset() {
        title = ""
        emoji = "✨"
        steps = []
        stepDraft = ""
        shareCircleIDs = []
    }
}

private struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
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
                y += rowHeight + spacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}

#Preview {
    NewQuestSheet(
        circles: [],
        onClose: {},
        onCreate: { _, _, _, _ in }
    )
}
