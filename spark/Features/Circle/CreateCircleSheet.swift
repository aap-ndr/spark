//
//  CreateCircleSheet.swift
//  Spark
//
//  Purpose:
//  Sheet for creating a new Spark Circle.
//
//  Responsibilities:
//  • Collects circle name and initial member details.
//

import SwiftUI

struct CreateCircleSheet: View {
    let onClose: () -> Void
    let onCreate: (String, String) -> Void
    let onJoin: (String) -> Void

    @State private var name = ""
    @State private var selectedEmoji = CircleContent.emojis[0]
    @State private var joinCode = ""
    @State private var showDiscardAlert = false

    private var hasUnsavedChanges: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || selectedEmoji != CircleContent.emojis[0]
            || !joinCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    sectionLabel("CIRCLE NAME")
                    TextField("e.g. Besties 💕", text: $name)
                        .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                        .padding(SparkSpacing.md)
                        .background(SparkColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        .onChange(of: name) { _, newValue in
                            if newValue.count > 24 {
                                name = String(newValue.prefix(24))
                            }
                        }
                        .padding(.top, SparkSpacing.xs)

                    sectionLabel("PICK AN EMOJI")
                        .padding(.top, SparkSpacing.lg)

                    emojiPicker
                        .padding(.top, SparkSpacing.xs)

                    joinDivider
                        .padding(.vertical, SparkSpacing.lg)

                    HStack(spacing: 10) {
                        TextField("ABC123", text: $joinCode)
                            .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                            .foregroundStyle(SparkColors.ink)
                            .textInputAutocapitalization(.characters)
                            .autocorrectionDisabled()
                            .padding(SparkSpacing.md)
                            .background(SparkColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                            .onChange(of: joinCode) { _, newValue in
                                joinCode = String(newValue.uppercased().prefix(6))
                            }

                        Button(action: joinCircle) {
                            Text("Join")
                                .font(SparkTypography.font(.displayBold, size: 15, relativeTo: .body))
                                .foregroundStyle(SparkColors.white)
                                .padding(.horizontal, 22)
                                .frame(minHeight: SparkSpacing.minimumTouchTarget)
                                .background(SparkColors.mint)
                                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(joinCode.trimmingCharacters(in: .whitespacesAndNewlines).count < 4)
                        .opacity(joinCode.trimmingCharacters(in: .whitespacesAndNewlines).count < 4 ? 0.5 : 1)
                        .accessibilityLabel("Join circle with code")
                    }
                }
                .padding(.horizontal, SparkSpacing.section)
                .padding(.bottom, 44)
            }
            .scrollIndicators(.hidden)
            .background(SparkColors.cream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New circle")
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
                    Button("Create") {
                        createCircle()
                    }
                    .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).count < 2)
                    .accessibilityLabel("Create circle")
                }
            }
        }
        .unsavedChangesDismissDisabled(hasUnsavedChanges)
        .discardChangesAlert(
            isPresented: $showDiscardAlert,
            message: UnsavedChangesGuard.formMessage("circle"),
            onDiscard: onClose
        )
    }

    private func requestClose() {
        if hasUnsavedChanges {
            showDiscardAlert = true
        } else {
            onClose()
        }
    }

    private var emojiPicker: some View {
        FlowLayout(spacing: 10) {
            ForEach(CircleContent.emojis, id: \.self) { emoji in
                Button {
                    SparkHaptics.lightImpact()
                    selectedEmoji = emoji
                } label: {
                    Text(emoji)
                        .font(.system(size: 22))
                        .frame(width: 48, height: 48)
                        .background(selectedEmoji == emoji ? SparkColors.lavender : SparkColors.card)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Emoji \(emoji)")
                .accessibilityAddTraits(selectedEmoji == emoji ? .isSelected : [])
            }
        }
    }

    private var joinDivider: some View {
        HStack(spacing: 10) {
            Rectangle()
                .fill(Color(sparkHex: 0xE9E2F5))
                .frame(height: 1)
            Text("or join with a code")
                .font(SparkTypography.font(.body, size: 12, relativeTo: .caption))
                .foregroundStyle(SparkColors.inkSoft)
            Rectangle()
                .fill(Color(sparkHex: 0xE9E2F5))
                .frame(height: 1)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
            .foregroundStyle(SparkColors.ink)
    }

    private func createCircle() {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 2 else { return }
        onCreate(trimmed, selectedEmoji)
        name = ""
        selectedEmoji = CircleContent.emojis[0]
    }

    private func joinCircle() {
        let trimmed = joinCode.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= 4 else { return }
        onJoin(trimmed)
        joinCode = ""
    }
}

private struct FlowLayout: Layout {
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
