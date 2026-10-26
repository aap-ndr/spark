//
//  SparkOutlineField.swift
//  Spark
//
//  Purpose:
//  Outlined text field for forms and composer sheets.
//
//  Responsibilities:
//  • Applies Spark border and typography styling to text input.
//

import SwiftUI

/// Outlined text field styled for onboarding and composer sheets.
struct SparkOutlineField: View {
    let title: String
    @Binding var text: String
    var placeholder: String = ""

    private var isActive: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: SparkSpacing.xs) {
            Text(title.uppercased())
                .font(SparkTypography.fieldLabel())
                .foregroundStyle(SparkColors.ink)

            TextField(placeholder, text: $text)
                .font(SparkTypography.fieldInput())
                .foregroundStyle(SparkColors.ink)
                .onChange(of: text) { _, newValue in
                    if newValue.count > 20 {
                        text = String(newValue.prefix(20))
                    }
                }
                .padding(.horizontal, SparkSpacing.lg)
                .padding(.vertical, SparkSpacing.buttonVertical)
                .background(SparkColors.card)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                        .stroke(
                            isActive ? SparkColors.lavender : SparkColors.inputBorderInactive,
                            lineWidth: 2
                        )
                }
        }
    }
}

#Preview {
    SparkOutlineField(title: "Your display name", text: .constant(""), placeholder: "e.g. Bella")
        .padding()
        .background(SparkColors.cream)
}
