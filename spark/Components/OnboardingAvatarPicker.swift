//
//  OnboardingAvatarPicker.swift
//  Spark
//
//  Purpose:
//  Preset avatar picker shown during onboarding.
//
//  Responsibilities:
//  • Presents selectable illustrated avatars in a horizontal grid.
//

import SwiftUI

/// Horizontal grid of preset avatars shown during onboarding.
struct OnboardingAvatarPicker: View {
    @Binding var selectedAvatarName: String
    @Environment(\.sparkSkin) private var skin

    private let columns = [
        GridItem(.adaptive(minimum: 70, maximum: 78), spacing: 14),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("CHOOSE YOUR AVATAR")
                .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                .foregroundStyle(SparkColors.ink)
                .padding(.bottom, 14)

            LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
                ForEach(Array(SparkAvatarCatalog.encodedPresets.enumerated()), id: \.offset) { index, encoded in
                    avatarTile(encoded: encoded, index: index)
                }
            }

            Text("You can fully customize this later in your profile. ✨")
                .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 12)
        }
    }

    private func avatarTile(encoded: String, index: Int) -> some View {
        let isSelected = selectedAvatarName == encoded

        return Button {
            SparkHaptics.lightImpact()
            selectedAvatarName = encoded
        } label: {
            AvatarView(avatarName: encoded, size: 64, showsRing: false)
        }
        .buttonStyle(.plain)
        .padding(3)
        .overlay {
            RoundedRectangle(cornerRadius: 38, style: .continuous)
                .stroke(isSelected ? skin.accent : Color.clear, lineWidth: 3)
        }
        .accessibilityLabel("Avatar option \(index + 1)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    OnboardingAvatarPicker(selectedAvatarName: .constant(SparkAvatarCatalog.defaultOnboardingAvatarName))
        .padding()
        .background(SparkColors.cream)
        .environment(\.sparkSkin, SparkSkinCatalog.defaultSkin)
}
