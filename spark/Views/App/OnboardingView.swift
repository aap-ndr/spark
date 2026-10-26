//
//  OnboardingView.swift
//  Spark
//
//  Purpose:
//  Initial onboarding flow that creates the local profile.
//
//  Responsibilities:
//  • Collects name, age confirmation, and avatar selection.
//

import SwiftUI

/// Initial onboarding flow that creates the user's local profile.
struct OnboardingView: View {
    @Environment(AppProfileStore.self) private var profileStore
    @Environment(\.sparkSkin) private var skin

    @State private var displayName = ""
    @State private var selectedAvatarName = SparkAvatarCatalog.defaultOnboardingAvatarName
    @State private var ageConfirmed = false

    private var nameValid: Bool {
        displayName.trimmingCharacters(in: .whitespacesAndNewlines).count >= 2
    }

    private var canContinue: Bool {
        nameValid && ageConfirmed && SparkAvatarCatalog.isSupportedAvatarName(selectedAvatarName)
    }

    var body: some View {
        ZStack(alignment: .top) {
            SparkColors.cream.ignoresSafeArea()

            skin.wash
                .frame(height: 320)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    copySection
                    nameSection
                    avatarSection
                    ageSection
                    actionSection
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.top, SparkSpacing.section)
                .padding(.bottom, 40)
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: SparkSpacing.md) {
            SparkLogoView(size: 124, isInteractive: true)

            HStack(spacing: SparkSpacing.xs) {
                SparkleBadge(size: 18)
                Text("Welcome to Spark")
                    .font(SparkTypography.welcomeBadge())
                    .foregroundStyle(SparkColors.lavender)
            }
            .padding(.horizontal, SparkSpacing.md)
            .padding(.vertical, SparkSpacing.xs)
            .background(SparkColors.card)
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
    }

    private var copySection: some View {
        VStack(alignment: .leading, spacing: SparkSpacing.xs) {
            Text("Let's begin! ✨")
                .sparkLargeTitle()
            Text("Pick a name and a character that feels like you. You can change this anytime.")
                .sparkBodyLarge()
                .lineSpacing(6)
        }
        .padding(.top, 28)
    }

    private var nameSection: some View {
        SparkOutlineField(
            title: "Your display name",
            text: $displayName,
            placeholder: "e.g. Bella"
        )
        .padding(.top, 26)
    }

    private var avatarSection: some View {
        OnboardingAvatarPicker(selectedAvatarName: $selectedAvatarName)
            .padding(.top, 26)
    }

    private var ageSection: some View {
        VStack(alignment: .leading, spacing: SparkSpacing.xs) {
            Button(action: toggleAgeConfirmation) {
                HStack(spacing: SparkSpacing.sm) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(ageConfirmed ? SparkColors.lavender : SparkColors.cream)
                            .frame(width: 26, height: 26)
                            .overlay {
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(
                                        ageConfirmed ? SparkColors.lavender : SparkColors.inputBorderCheckboxInactive,
                                        lineWidth: 2
                                    )
                            }

                        if ageConfirmed {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(SparkColors.white)
                        }
                    }

                    Text("I confirm I am 13 years or older.")
                        .font(SparkTypography.body())
                        .foregroundStyle(SparkColors.ink)
                        .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(SparkSpacing.md)
                .background(SparkColors.card)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                        .stroke(
                            ageConfirmed ? SparkColors.lavender : SparkColors.inputBorderInactive,
                            lineWidth: 2
                        )
                }
            }
            .buttonStyle(.plain)

            if !ageConfirmed {
                Text("Please confirm to continue")
                    .font(SparkTypography.supportive())
                    .foregroundStyle(SparkColors.pink)
                    .padding(.top, SparkSpacing.xs)
                    .padding(.leading, SparkSpacing.xxs)
            }
        }
        .padding(.top, 28)
    }

    private var actionSection: some View {
        VStack(spacing: SparkSpacing.sm) {
            SparkPrimaryButton(
                label: "Start my adventure",
                gradient: LinearGradient(
                    colors: [SparkColors.pink, SparkColors.lavender],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                isEnabled: canContinue,
                showsSparkleIcon: true
            ) {
                profileStore.createProfile(
                    displayName: displayName,
                    avatarName: selectedAvatarName
                )
            }

            Text("A safe, cozy space made for brains like yours 💗")
                .font(SparkTypography.supportive())
                .foregroundStyle(SparkColors.inkSoft)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.top, 14)
        }
        .padding(.top, SparkSpacing.section)
    }

    private func toggleAgeConfirmation() {
        SparkHaptics.lightImpact()
        ageConfirmed.toggle()
    }
}

#Preview {
    OnboardingView()
        .environment(AppProfileStore())
        .environment(\.sparkSkin, SparkSkinCatalog.defaultSkin)
        .preferredColorScheme(.light)
}
