//
//  CategoryComposerSheet.swift
//  Spark
//
//  Purpose:
//  Composer for reminder categories.
//
//  Responsibilities:
//  • Creates and edits user-defined reminder categories.
//

import SwiftUI

struct CategoryComposerSheet: View {
    let onClose: () -> Void
    let onCreate: (String, String) -> Void

    @State private var label = ""
    @State private var emoji = RemindersContent.categoryEmojiPresets[0]
    @State private var showDiscardAlert = false

    private var hasUnsavedChanges: Bool {
        !label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || emoji != RemindersContent.categoryEmojiPresets[0]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    nameSection
                    emojiSection
                }
                .padding(.horizontal, SparkSpacing.section)
                .padding(.bottom, 44)
            }
            .scrollIndicators(.hidden)
            .background(SparkColors.cream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New category")
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
                    Button("Add") {
                        save()
                    }
                    .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                    .disabled(label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("Add category")
                }
            }
        }
        .unsavedChangesDismissDisabled(hasUnsavedChanges)
        .discardChangesAlert(
            isPresented: $showDiscardAlert,
            message: UnsavedChangesGuard.formMessage("category"),
            onDiscard: onClose
        )
        .onAppear {
            label = ""
            emoji = RemindersContent.categoryEmojiPresets[0]
        }
    }

    private var nameSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("NAME")
            TextField("e.g. Skincare, School…", text: $label)
                .font(SparkTypography.bodyLarge())
                .foregroundStyle(SparkColors.ink)
                .padding(.horizontal, SparkSpacing.md)
                .padding(.vertical, 14)
                .background(SparkColors.card)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .sparkSoftShadow()
                .padding(.top, 10)
        }
        .padding(.top, SparkSpacing.sm)
    }

    private var emojiSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("PICK AN EMOJI")
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 48), spacing: 10)], spacing: 10) {
                ForEach(RemindersContent.categoryEmojiPresets, id: \.self) { item in
                    emojiButton(item)
                }
            }
            .padding(.top, 10)
        }
        .padding(.top, SparkSpacing.lg)
    }

    private func emojiButton(_ item: String) -> some View {
        let active = item == emoji

        return Button {
            SparkHaptics.lightImpact()
            emoji = item
        } label: {
            Text(item)
                .font(.system(size: 22))
                .frame(width: 48, height: 48)
                .background(active ? SparkColors.lavender : SparkColors.card)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Emoji \(item)")
        .accessibilityAddTraits(active ? .isSelected : [])
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

    private func save() {
        let trimmed = label.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        SparkHaptics.successNotification()
        onCreate(trimmed, emoji)
    }
}
