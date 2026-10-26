//
//  SparkDesignShowcaseView.swift
//  Spark
//
//  Purpose:
//  Design system showcase used for local UI review.
//
//  Responsibilities:
//  • Demonstrates core Spark components outside production flows.
//

import SwiftUI

struct SparkDesignShowcaseView: View {
    @Environment(\.sparkSkin) private var skin
    @State private var displayName = ""

    var body: some View {
        ZStack(alignment: .top) {
            SparkColors.cream.ignoresSafeArea()

            skin.wash
                .frame(height: 320)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: SparkSpacing.section) {
                    logoSection
                    typographySection
                    avatarSection
                    statChipSection
                    cardSection
                    outlineFieldSection
                    buttonSection
                    badgeSection
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.vertical, SparkSpacing.section)
            }
        }
        .navigationTitle("Design Showcase")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var logoSection: some View {
        VStack(spacing: SparkSpacing.md) {
            SparkLogoView(size: 96, isInteractive: true)

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

    private var typographySection: some View {
        VStack(alignment: .leading, spacing: SparkSpacing.xs) {
            Text("Let's begin! ✨")
                .sparkLargeTitle()
            Text("Pick a name and a character that feels like you. You can change this anytime.")
                .sparkBodyLarge()
                .lineSpacing(6)
        }
    }

    private var avatarSection: some View {
        VStack(alignment: .leading, spacing: SparkSpacing.sm) {
            Text("CHOOSE YOUR AVATAR")
                .font(SparkTypography.fieldLabel())
                .foregroundStyle(SparkColors.ink)

            HStack(spacing: SparkSpacing.lg) {
                AvatarView(avatarName: SparkAvatarCatalog.defaultOnboardingAvatarName, showsRing: false)
                AvatarView(avatarName: SparkAvatarCatalog.encodedPresets[1], showsRing: false)
                AvatarView(avatarName: SparkAvatarCatalog.defaultAvatarName, showsRing: false)
            }
        }
    }

    private var statChipSection: some View {
        HStack(spacing: SparkSpacing.sm) {
            HStack(spacing: SparkSpacing.sm) {
                SparkleBadge(size: 22)
                VStack(alignment: .leading, spacing: 2) {
                    Text("12")
                        .font(SparkTypography.statValue())
                        .foregroundStyle(SparkColors.ink)
                    Text("Sparks earned")
                        .sparkCaption()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 14)
            .padding(.horizontal, SparkSpacing.md)
            .background(SparkColors.yellowSoft)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
            .sparkSoftShadow()
        }
    }

    private var cardSection: some View {
        SparkCard {
            VStack(alignment: .leading, spacing: SparkSpacing.sm) {
                Text("Upcoming")
                    .sparkSectionTitle()
                Text("A card surface from the React Native home screen.")
                    .sparkSupportive()
                Divider().overlay(SparkColors.divider)
                SparkAccentLink(title: "See all") {}
            }
        }
    }

    private var outlineFieldSection: some View {
        SparkOutlineField(
            title: "Your display name",
            text: $displayName,
            placeholder: "e.g. Bella"
        )
    }

    private var buttonSection: some View {
        VStack(spacing: SparkSpacing.sm) {
            SparkPrimaryButton(label: "Start my adventure") {}
            SparkPrimaryButton(label: "Disabled", isEnabled: false) {}
        }
    }

    private var badgeSection: some View {
        HStack(spacing: SparkSpacing.sm) {
            SparkMarkView(size: 26)
            Text("Spark mark accent")
                .sparkSupportive()
        }
    }
}

#Preview {
    NavigationStack {
        SparkDesignShowcaseView()
    }
    .environment(\.sparkSkin, SparkSkinCatalog.defaultSkin)
    .preferredColorScheme(.light)
}
