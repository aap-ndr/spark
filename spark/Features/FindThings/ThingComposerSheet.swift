//
//  ThingComposerSheet.swift
//  Spark
//
//  Purpose:
//  Composer for storing a new tracked item.
//
//  Responsibilities:
//  • Captures item name, category, and location notes.
//

import SwiftUI

struct ThingComposerSheet: View {
    let editing: StoredItem?
    let onClose: () -> Void
    let onSave: (ThingComposerInput) -> Void

    @State private var name = ""
    @State private var emoji: String?
    @State private var location = ""
    @State private var note = ""
    @State private var category: ThingCategory = .other
    @State private var originalSnapshot = ThingDraftSnapshot.empty
    @State private var showDiscardAlert = false

    private var hasUnsavedChanges: Bool {
        currentSnapshot() != originalSnapshot
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    quickPickSection
                    nameSection
                    categorySection
                    locationSection
                    noteSection
                }
                .padding(.horizontal, SparkSpacing.section)
                .padding(.bottom, 44)
            }
            .scrollIndicators(.hidden)
            .background(SparkColors.cream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editing == nil ? "Where is it?" : "Update location")
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
                    Button("Save") {
                        save()
                    }
                    .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                    .disabled(!canSave)
                    .accessibilityLabel(editing == nil ? "Save item" : "Save location")
                }
            }
        }
        .unsavedChangesDismissDisabled(hasUnsavedChanges)
        .discardChangesAlert(
            isPresented: $showDiscardAlert,
            message: UnsavedChangesGuard.formMessage("item"),
            onDiscard: onClose
        )
        .onAppear(perform: resetFields)
        .onChange(of: editing?.id) { _, _ in
            resetFields()
        }
    }

    private var canSave: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedName.isEmpty, !trimmedLocation.isEmpty { return true }
        if let editing {
            return !editing.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                && !editing.location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        return false
    }

    private var quickPickSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("QUICK PICK")
            ThingsFlowLayout(spacing: 8, rowSpacing: 8) {
                ForEach(ThingsContent.quickItems) { item in
                    quickPickChip(item)
                }
            }
            .padding(.top, 10)
        }
        .padding(.top, SparkSpacing.sm)
    }

    private func quickPickChip(_ item: ThingQuickPick) -> some View {
        let active = name.trimmingCharacters(in: .whitespacesAndNewlines) == item.name

        return Button {
            SparkHaptics.lightImpact()
            name = item.name
            emoji = item.emoji
            category = item.category
        } label: {
            HStack(spacing: 6) {
                Text(item.emoji)
                    .font(.system(size: 15))
                Text(item.name)
                    .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
            }
            .padding(.horizontal, SparkSpacing.sm)
            .padding(.vertical, 9)
            .background(active ? SparkColors.mint : SparkColors.card)
            .clipShape(Capsule())
            .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.name)
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("WHAT IS IT?")
            TextField("e.g. Glasses", text: $name)
                .font(SparkTypography.bodyLarge())
                .foregroundStyle(SparkColors.ink)
                .padding(.horizontal, SparkSpacing.md)
                .padding(.vertical, 14)
                .background(SparkColors.card)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .sparkSoftShadow()
                .padding(.top, 10)
        }
        .padding(.top, SparkSpacing.lg)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("CATEGORY")
            ThingsFlowLayout(spacing: 8, rowSpacing: 8) {
                ForEach(ThingsContent.categories) { item in
                    categoryChip(item)
                }
            }
            .padding(.top, 10)
        }
        .padding(.top, SparkSpacing.lg)
    }

    private func categoryChip(_ item: ThingCategoryMeta) -> some View {
        let active = category == item.id

        return Button {
            SparkHaptics.lightImpact()
            category = item.id
        } label: {
            HStack(spacing: 6) {
                Text(item.emoji)
                    .font(.system(size: 15))
                Text(item.label)
                    .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
            }
            .padding(.horizontal, SparkSpacing.sm)
            .padding(.vertical, 9)
            .background(active ? SparkColors.mint : SparkColors.card)
            .clipShape(Capsule())
            .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.label)
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("WHERE DID YOU PUT IT?")
            TextField("e.g. On the kitchen counter", text: $location)
                .font(SparkTypography.bodyLarge())
                .foregroundStyle(SparkColors.ink)
                .padding(.horizontal, SparkSpacing.md)
                .padding(.vertical, 14)
                .background(SparkColors.card)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .sparkSoftShadow()
                .padding(.top, 10)
        }
        .padding(.top, SparkSpacing.lg)
    }

    private var noteSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("NOTE (OPTIONAL)")
            TextField("Any extra detail…", text: $note, axis: .vertical)
                .font(SparkTypography.bodyLarge())
                .foregroundStyle(SparkColors.ink)
                .lineLimit(3...6)
                .padding(.horizontal, SparkSpacing.md)
                .padding(.vertical, 14)
                .background(SparkColors.card)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .sparkSoftShadow()
                .padding(.top, 10)
        }
        .padding(.top, SparkSpacing.lg)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
            .foregroundStyle(SparkColors.inkSoft)
    }

    private func requestClose() {
        if hasUnsavedChanges {
            showDiscardAlert = true
        } else {
            onClose()
        }
    }

    private func currentSnapshot() -> ThingDraftSnapshot {
        ThingDraftSnapshot(
            name: name,
            emoji: emoji,
            location: location,
            note: note,
            category: category
        )
    }

    private func resetFields() {
        if let editing {
            name = editing.name
            emoji = editing.emoji
            location = editing.location
            note = editing.note ?? ""
            category = ThingsContent.category(of: editing)
        } else {
            name = ""
            emoji = nil
            location = ""
            note = ""
            category = .other
        }
        originalSnapshot = currentSnapshot()
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedLocation = location.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedName = trimmedName.isEmpty ? editing?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" : trimmedName
        let resolvedLocation = trimmedLocation.isEmpty ? editing?.location.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" : trimmedLocation
        guard !resolvedName.isEmpty, !resolvedLocation.isEmpty else { return }

        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)
        onSave(
            ThingComposerInput(
                name: resolvedName,
                location: resolvedLocation,
                note: trimmedNote.isEmpty ? nil : trimmedNote,
                emoji: emoji,
                category: category
            )
        )
    }
}

private struct ThingDraftSnapshot: Equatable {
    var name: String
    var emoji: String?
    var location: String
    var note: String
    var category: ThingCategory

    static let empty = ThingDraftSnapshot(
        name: "",
        emoji: nil,
        location: "",
        note: "",
        category: .other
    )
}

private struct ThingsFlowLayout: Layout {
    var spacing: CGFloat
    var rowSpacing: CGFloat

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
                origin.y += rowHeight + rowSpacing
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
