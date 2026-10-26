//
//  MeView.swift
//  Spark
//
//  Purpose:
//  Profile tab with stats, skin picker, and settings entry points.
//
//  Responsibilities:
//  • Shows user profile summary, affirmation, and app tour access.
//  • Edits profile details and switches app skins.
//

import SwiftUI

/// Profile tab with stats, affirmation, skin picker, and app tour entry point.
struct MeView: View {
    @Environment(AppProfileStore.self) private var profileStore
    @Environment(SkinStore.self) private var skinStore
    @Environment(CircleStore.self) private var circleStore
    @Environment(SavedOpportunitiesStore.self) private var savedOpportunitiesStore

    @State private var editOpen = false
    @State private var tourOpen = false

    private var profile: UserProfile? { profileStore.profile }

    private var circleCount: Int { circleStore.circles.count }
    private var sparkCount: Int { circleStore.messages.count }
    private var savedCount: Int { savedOpportunitiesStore.saved.count }

    private var showsAboutCard: Bool {
        hasText(profile?.bio) || hasText(profile?.likes) || hasText(profile?.dislikes)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                statsSection
                affirmationSection
                if showsAboutCard {
                    aboutSection
                }
                tourSection
                appVibeSection
                memberSinceSection
            }
            .padding(.bottom, 40)
        }
        .scrollIndicators(.hidden)
        .background(SparkColors.cream)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $editOpen) {
            EditProfileSheet(
                profile: profile,
                skin: skinStore.activeSkin,
                onClose: { editOpen = false },
                onSave: { name, avatar, bio, likes, dislikes in
                    profileStore.saveProfileEdit(
                        displayName: name,
                        avatarName: avatar,
                        bio: bio,
                        likes: likes,
                        dislikes: dislikes
                    )
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $tourOpen) {
            AppTourView { tourOpen = false }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                AvatarView(
                    avatarName: profile?.avatarName ?? SparkAvatarCatalog.defaultAvatarName,
                    size: 104
                )
                .padding(.top, 30)

                Text(profile?.displayName ?? "friend")
                    .font(SparkTypography.font(.displayBold, size: 26, relativeTo: .title2))
                    .foregroundStyle(SparkColors.white)
                    .padding(.top, 14)

                if let bio = profile?.bio, hasText(bio) {
                    Text(bio)
                        .font(SparkTypography.font(.body, size: 14, relativeTo: .subheadline))
                        .foregroundStyle(SparkColors.white.opacity(0.92))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .frame(maxWidth: 300)
                        .padding(.top, 6)
                }

                Button(action: openEdit) {
                    HStack(spacing: 6) {
                        Image(systemName: "pencil")
                            .font(.system(size: 15, weight: .semibold))
                        Text("Edit profile")
                            .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                    }
                    .foregroundStyle(SparkColors.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.white.opacity(0.35))
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
                .accessibilityLabel("Edit profile")
            }
            .padding(.bottom, 34)
            .frame(maxWidth: .infinity)
            .background(skinStore.activeSkin.gradient)
            .clipShape(
                UnevenRoundedRectangle(
                    cornerRadii: .init(bottomLeading: SparkRadius.xl, bottomTrailing: SparkRadius.xl),
                    style: .continuous
                )
            )
        }
    }

    // MARK: - Stats

    private var statsSection: some View {
        HStack(spacing: SparkSpacing.sm) {
            statCard(
                value: circleCount,
                label: "Circles",
                icon: "person.3.fill",
                iconColor: SparkColors.lavender,
                background: SparkColors.lavenderSoft
            )
            statCard(
                value: sparkCount,
                label: "Sparks",
                icon: "sparkles",
                iconColor: SparkColors.pink,
                background: SparkColors.pinkSoft
            )
            statCard(
                value: savedCount,
                label: "Saved",
                icon: "bookmark.fill",
                iconColor: SparkColors.mint,
                background: SparkColors.mintSoft
            )
        }
        .padding(.horizontal, SparkSpacing.xxl)
        .offset(y: -18)
        .sparkFadeInDown(duration: 0.4)
    }

    private func statCard(value: Int, label: String, icon: String, iconColor: Color, background: Color) -> some View {
        SparkCard {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(background)
                        .frame(width: 40, height: 40)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(iconColor)
                }
                Text("\(value)")
                    .font(SparkTypography.font(.displayBold, size: 22, relativeTo: .title3))
                    .foregroundStyle(SparkColors.ink)
                    .padding(.top, 8)
                Text(label)
                    .font(SparkTypography.font(.body, size: 12, relativeTo: .footnote))
                    .foregroundStyle(SparkColors.inkSoft)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }

    // MARK: - Affirmation

    private var affirmationSection: some View {
        SparkCard(backgroundColor: SparkColors.yellowSoft) {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SparkColors.yellow)
                Text("YOU ARE")
                    .font(SparkTypography.font(.bodyExtra, size: 12, relativeTo: .footnote))
                    .foregroundStyle(Color(sparkHex: 0xD9A420))
            }
            Text("Creative, resilient, and wonderfully wired. Your ADHD is a superpower. 💛")
                .font(SparkTypography.font(.displayBold, size: 19, relativeTo: .body))
                .foregroundStyle(SparkColors.ink)
                .lineSpacing(7)
                .padding(.top, 8)
        }
        .padding(.horizontal, SparkSpacing.xxl)
        .padding(.top, 22)
    }

    // MARK: - About

    private var aboutSection: some View {
        SparkCard {
            Text("ABOUT ME")
                .font(SparkTypography.font(.bodyExtra, size: 12, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)

            if let bio = profile?.bio, hasText(bio) {
                aboutRow(emoji: "✨", title: "About me", value: bio)
                    .padding(.top, 12)
            }
            if let likes = profile?.likes, hasText(likes) {
                aboutRow(emoji: "💛", title: "Things I like", value: likes)
                    .padding(.top, 14)
            }
            if let dislikes = profile?.dislikes, hasText(dislikes) {
                aboutRow(emoji: "🙅‍♀️", title: "Things I don't like", value: dislikes)
                    .padding(.top, 14)
            }
        }
        .padding(.horizontal, SparkSpacing.xxl)
        .padding(.top, 22)
    }

    private func aboutRow(emoji: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text(emoji)
                .font(.system(size: 18))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                    .foregroundStyle(SparkColors.inkSoft)
                Text(value)
                    .font(SparkTypography.font(.body, size: 15, relativeTo: .body))
                    .foregroundStyle(SparkColors.ink)
                    .lineSpacing(6)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Tour

    private var tourSection: some View {
        SparkPressableCard(action: {
            SparkHaptics.lightImpact()
            tourOpen = true
        }) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                        .fill(SparkColors.lavenderSoft)
                        .frame(width: 46, height: 46)
                    Image(systemName: "safari")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(SparkColors.lavender)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("How this app works")
                        .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                    Text("Take the quick tour again anytime ✨")
                        .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.inkSoft)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SparkColors.inkSoft)
            }
        }
        .padding(.horizontal, SparkSpacing.xxl)
        .padding(.top, 22)
    }

    // MARK: - App Vibe

    private var appVibeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("App Vibe")
                .font(SparkTypography.sectionTitle())
                .foregroundStyle(SparkColors.ink)
            Text("Pick a vibe — it sets your highlight color and the \"Today's Spark\" card. 🎨")
                .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 2)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
                spacing: 12
            ) {
                ForEach(SparkSkinCatalog.all) { skinOption in
                    skinTile(skinOption)
                }
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, SparkSpacing.xxl)
        .padding(.top, 28)
    }

    private func skinTile(_ skinOption: SparkSkin) -> some View {
        let selected = skinStore.skinId == skinOption.id

        return Button {
            SparkHaptics.lightImpact()
            skinStore.setSkin(skinOption.id)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                        .fill(skinOption.gradient)
                        .frame(height: 64)
                        .overlay(alignment: .topTrailing) {
                            Text(skinOption.emoji)
                                .font(.system(size: 22))
                                .padding(8)
                        }

                    if selected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(skinOption.accent)
                            .padding(6)
                            .background(SparkColors.white)
                            .clipShape(Circle())
                            .padding(8)
                    }
                }

                Text(skinOption.name)
                    .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(SparkColors.ink)
                    .padding(.top, 8)
                Text(skinOption.tagline)
                    .font(SparkTypography.font(.body, size: 12, relativeTo: .footnote))
                    .foregroundStyle(SparkColors.inkSoft)
                    .lineLimit(1)
                    .padding(.top, 1)
            }
            .padding(10)
            .background(SparkColors.card)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous)
                    .strokeBorder(selected ? skinOption.accent : Color.clear, lineWidth: 2)
            }
            .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(skinOption.name), \(skinOption.tagline)")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    // MARK: - Footer

    @ViewBuilder
    private var memberSinceSection: some View {
        if let profile {
            Text("✨ Sparking since \(memberSinceLabel(profile.createdAt))")
                .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
                .padding(.top, 24)
        }
    }

    // MARK: - Helpers

    private func openEdit() {
        SparkHaptics.lightImpact()
        editOpen = true
    }

    private func hasText(_ value: String?) -> Bool {
        guard let value else { return false }
        return !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func memberSinceLabel(_ createdAt: Int64) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000)
        return date.formatted(date: .numeric, time: .omitted)
    }
}

#Preview {
    let profileStore = AppProfileStore()
    profileStore.createProfile(displayName: "Bella", avatarName: SparkAvatarCatalog.defaultAvatarName)
    profileStore.updateProfile(bio: "I am a artist", likes: "Painting", dislikes: "Spiders")

    return NavigationStack {
        MeView()
            .environment(profileStore)
            .environment(SkinStore())
            .environment(CircleStore())
            .environment(SavedOpportunitiesStore())
            .environment(\.sparkSkin, SparkSkinCatalog.defaultSkin)
    }
}
