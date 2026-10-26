//
//  SparkComposerSheet.swift
//  Spark
//
//  Purpose:
//  Composer for sending sparks to circle members.
//
//  Responsibilities:
//  • Creates spark messages with emoji and recipient selection.
//

import SwiftUI

struct SparkComposerSheet: View {
    @Binding var draft: String
    let onClose: () -> Void
    let onSend: (String) -> Void

    @State private var selectedVibe: SparkVibe = .cheer
    @State private var showDiscardAlert = false

    private var hasUnsavedChanges: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var filteredTemplates: [SparkTemplate] {
        SparkLibrary.templates(for: selectedVibe)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        vibeChips
                            .padding(.top, SparkSpacing.md)

                        VStack(spacing: 10) {
                            ForEach(filteredTemplates) { template in
                                templateButton(template)
                            }
                        }
                        .padding(.horizontal, SparkSpacing.screenHorizontal)
                        .padding(.top, 14)
                    }
                }
                .scrollIndicators(.hidden)

                VStack(spacing: SparkSpacing.sm) {
                    TextField("Write your own warm message…", text: $draft, axis: .vertical)
                        .font(SparkTypography.body())
                        .foregroundStyle(SparkColors.ink)
                        .lineLimit(3...6)
                        .padding(15)
                        .background(SparkColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        .onChange(of: draft) { _, newValue in
                            if newValue.count > 160 {
                                draft = String(newValue.prefix(160))
                            }
                        }
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.top, 6)
                .padding(.bottom, SparkSpacing.section)
            }
            .background(SparkColors.cream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Send a Spark ✨")
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
                    Button("Send") {
                        onSend(draft)
                    }
                    .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .accessibilityLabel("Send spark")
                }
            }
        }
        .unsavedChangesDismissDisabled(hasUnsavedChanges)
        .discardChangesAlert(
            isPresented: $showDiscardAlert,
            message: UnsavedChangesGuard.formMessage("spark"),
            onDiscard: {
                draft = ""
                onClose()
            }
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

    private var vibeChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SparkSpacing.xs) {
                ForEach(SparkVibe.allCases, id: \.self) { vibe in
                    let active = selectedVibe == vibe
                    Button {
                        SparkHaptics.lightImpact()
                        selectedVibe = vibe
                    } label: {
                        Text(SparkLibrary.vibeLabels[vibe] ?? vibe.rawValue)
                            .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                            .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
                            .padding(.horizontal, SparkSpacing.md)
                            .padding(.vertical, 9)
                            .background(active ? SparkColors.lavender : SparkColors.card)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityAddTraits(active ? .isSelected : [])
                }
            }
            .padding(.horizontal, SparkSpacing.screenHorizontal)
        }
    }

    private func templateButton(_ template: SparkTemplate) -> some View {
        let selected = draft == template.text

        return Button {
            SparkHaptics.lightImpact()
            draft = template.text
        } label: {
            Text(template.text)
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.ink)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(15)
                .background(selected ? SparkColors.lavenderSoft : SparkColors.card)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                        .strokeBorder(selected ? SparkColors.lavender : Color.clear, lineWidth: 2)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(template.text)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}
