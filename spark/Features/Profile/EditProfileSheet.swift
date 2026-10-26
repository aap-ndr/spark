//
//  EditProfileSheet.swift
//  Spark
//
//  Purpose:
//  Profile editing sheet with unsaved-change protection.
//
//  Responsibilities:
//  • Edits display name, avatar, bio, likes, and dislikes.
//  • Guards dismissal and coordinates nested avatar builder drafts.
//

import SwiftUI
import PhotosUI

#if canImport(UIKit)
import UIKit
#endif

/// Sheet for editing display name, avatar, bio, likes, and dislikes with unsaved-change protection.
struct EditProfileSheet: View {
    let profile: UserProfile?
    let skin: SparkSkin
    let onClose: () -> Void
    let onSave: (String, String, String, String, String) -> Bool

    @State private var originalSnapshot = NormalizedProfileDraft.from(profile: nil)
    @State private var name = ""
    @State private var avatar = SparkAvatarCatalog.defaultAvatarName
    @State private var bio = ""
    @State private var likes = ""
    @State private var dislikes = ""
    @State private var builderOpen = false
    @State private var photoItem: PhotosPickerItem?
    @State private var photoNote: String?
    @State private var photoDenied = false
    @State private var showDiscardAlert = false

    private var normalizedDraft: NormalizedProfileDraft {
        NormalizedProfileDraft.normalize(
            displayName: name,
            avatarName: avatar,
            bio: bio,
            likes: likes,
            dislikes: dislikes
        )
    }

    private var hasUnsavedChanges: Bool {
        normalizedDraft != originalSnapshot
    }

    private var nameValidationMessage: String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            return "Display name is required."
        }
        if trimmed.count < 2 {
            return "Display name must be at least 2 characters."
        }
        if trimmed.count > 20 {
            return "Display name must be 20 characters or fewer."
        }
        return nil
    }

    private var nameValid: Bool {
        nameValidationMessage == nil
    }

    private var builderInitial: AvatarConfig {
        SparkAvatarCatalog.decode(avatar) ?? SparkAvatarCatalog.defaultConfig
    }

    var body: some View {
        Group {
            if builderOpen {
                AvatarBuilderView(
                    initial: builderInitial,
                    gradient: skin.gradient,
                    onSave: { encoded in
                        avatar = encoded
                        builderOpen = false
                    },
                    onCancel: { builderOpen = false }
                )
            } else {
                editForm
            }
        }
        .onAppear(perform: loadDraftFromProfile)
    }

    private var editForm: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Edit your profile")
                        .font(SparkTypography.font(.displayBold, size: 22, relativeTo: .title3))
                        .foregroundStyle(SparkColors.ink)

                    fieldLabel("DISPLAY NAME", icon: nil)
                    TextField("Your name", text: $name)
                        .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                        .padding(SparkSpacing.md)
                        .background(SparkColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        .onChange(of: name) { _, newValue in
                            if newValue.count > 20 {
                                name = String(newValue.prefix(20))
                            }
                        }

                    if let nameValidationMessage, !nameValid {
                        Text(nameValidationMessage)
                            .font(SparkTypography.supportive())
                            .foregroundStyle(SparkColors.pink)
                            .padding(.top, SparkSpacing.sm)
                    }

                    fieldLabel("ABOUT ME", icon: "sparkles")
                    TextField("A short one-liner about you ✨", text: $bio)
                        .font(SparkTypography.body())
                        .padding(SparkSpacing.md)
                        .background(SparkColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        .onChange(of: bio) { _, newValue in
                            if newValue.count > 80 { bio = String(newValue.prefix(80)) }
                        }

                    fieldLabel("THINGS I LIKE", icon: "heart.fill", filled: true, color: SparkColors.pink)
                    TextField("Painting, cats, rainy days…", text: $likes, axis: .vertical)
                        .font(SparkTypography.body())
                        .lineLimit(3...6)
                        .padding(SparkSpacing.md)
                        .frame(minHeight: 56, alignment: .topLeading)
                        .background(SparkColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        .onChange(of: likes) { _, newValue in
                            if newValue.count > 140 { likes = String(newValue.prefix(140)) }
                        }

                    fieldLabel("THINGS I DON'T LIKE", icon: "hand.thumbsdown.fill")
                    TextField("Loud noises, spiders…", text: $dislikes, axis: .vertical)
                        .font(SparkTypography.body())
                        .lineLimit(3...6)
                        .padding(SparkSpacing.md)
                        .frame(minHeight: 56, alignment: .topLeading)
                        .background(SparkColors.card)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        .onChange(of: dislikes) { _, newValue in
                            if newValue.count > 140 { dislikes = String(newValue.prefix(140)) }
                        }

                    Text("YOUR AVATAR")
                        .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.ink)
                        .padding(.top, SparkSpacing.lg)
                        .padding(.bottom, 12)

                    avatarActionRow(
                        title: "Customize avatar",
                        subtitle: "Skin, hair, glasses, freckles & more",
                        icon: "wand.and.stars",
                        iconColor: SparkColors.lavender,
                        leading: { AvatarView(avatarName: avatar, size: 58) },
                        action: { builderOpen = true }
                    )

                    PhotosPicker(selection: $photoItem, matching: .images, photoLibrary: .shared()) {
                        avatarActionRowContent(
                            title: "Upload a photo",
                            subtitle: "Use a picture of you — cropped to a circle",
                            icon: "photo.badge.plus",
                            iconColor: SparkColors.pink,
                            leading: {
                                ZStack {
                                    Circle()
                                        .fill(SparkColors.pinkSoft)
                                        .frame(width: 58, height: 58)
                                    Image(systemName: "photo.badge.plus")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundStyle(SparkColors.pink)
                                }
                            }
                        )
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 12)
                    .onChange(of: photoItem) { _, item in
                        guard let item else { return }
                        Task { await importPhoto(item) }
                    }

                    if let photoNote {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(photoNote)
                                .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                                .foregroundStyle(SparkColors.ink)
                            if photoDenied {
                                Button {
                                    openSettings()
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: "gearshape.fill")
                                        Text("Open Settings")
                                    }
                                    .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                                    .foregroundStyle(SparkColors.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 9)
                                    .background(SparkColors.pink)
                                    .clipShape(Capsule())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(12)
                        .background(SparkColors.pinkSoft)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        .padding(.top, 10)
                    }

                    Text("OR PICK A READY-MADE LOOK")
                        .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.inkSoft)
                        .padding(.top, SparkSpacing.lg)
                        .padding(.bottom, 10)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(SparkAvatarCatalog.encodedPresets.enumerated()), id: \.offset) { _, encoded in
                                let selected = avatar == encoded
                                Button {
                                    SparkHaptics.lightImpact()
                                    avatar = encoded
                                } label: {
                                    AvatarView(avatarName: encoded, size: 64, showsRing: false)
                                        .overlay {
                                            Circle()
                                                .strokeBorder(selected ? skin.accent : Color.clear, lineWidth: 3)
                                                .padding(1)
                                        }
                                }
                                .buttonStyle(.plain)
                                .accessibilityAddTraits(selected ? .isSelected : [])
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding(SparkSpacing.section)
                .padding(.bottom, 24)
            }
            .scrollIndicators(.hidden)
            .background(SparkColors.cream)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: requestClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(SparkColors.inkSoft)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                    .disabled(!nameValid)
                    .accessibilityLabel("Save changes")
                }
            }
        }
        .unsavedChangesDismissDisabled(hasUnsavedChanges)
        .discardChangesAlert(
            isPresented: $showDiscardAlert,
            message: UnsavedChangesGuard.profileMessage(),
            onDiscard: onClose
        )
    }

    private func fieldLabel(_ text: String, icon: String?, filled: Bool = false, color: Color = SparkColors.lavender) -> some View {
        HStack(spacing: 6) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .symbolVariant(filled ? .fill : .none)
                    .foregroundStyle(color)
            }
            Text(text)
                .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.ink)
        }
        .padding(.top, SparkSpacing.lg)
        .padding(.bottom, 8)
    }

    private func avatarActionRow<Leading: View>(
        title: String,
        subtitle: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder leading: () -> Leading,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            SparkHaptics.lightImpact()
            action()
        }) {
            avatarActionRowContent(title: title, subtitle: subtitle, icon: icon, iconColor: iconColor, leading: leading)
        }
        .buttonStyle(.plain)
    }

    private func avatarActionRowContent<Leading: View>(
        title: String,
        subtitle: String,
        icon: String,
        iconColor: Color,
        @ViewBuilder leading: () -> Leading
    ) -> some View {
        HStack(spacing: 14) {
            leading()
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(iconColor)
                    Text(title)
                        .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                }
                Text(subtitle)
                    .font(SparkTypography.font(.body, size: 12, relativeTo: .footnote))
                    .foregroundStyle(SparkColors.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(SparkColors.inkSoft)
        }
        .padding(12)
        .background(SparkColors.card)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
        .sparkSoftShadow()
    }

    private func loadDraftFromProfile() {
        originalSnapshot = NormalizedProfileDraft.from(profile: profile)
        name = profile?.displayName ?? ""
        avatar = profile?.avatarName ?? SparkAvatarCatalog.defaultAvatarName
        bio = profile?.bio ?? ""
        likes = profile?.likes ?? ""
        dislikes = profile?.dislikes ?? ""
        photoNote = nil
        photoDenied = false
        builderOpen = false
    }

    private func requestClose() {
        if hasUnsavedChanges {
            showDiscardAlert = true
        } else {
            onClose()
        }
    }

    private func saveChanges() {
        guard nameValid else { return }
        if onSave(name, avatar, bio, likes, dislikes) {
            originalSnapshot = normalizedDraft
            SparkHaptics.successNotification()
            onClose()
        }
    }

    private func importPhoto(_ item: PhotosPickerItem) async {
        photoNote = nil
        photoDenied = false
        guard let data = try? await item.loadTransferable(type: Data.self) else {
            await MainActor.run {
                photoNote = "We couldn't load that photo. Try another one. 💜"
            }
            return
        }
        let filename = "avatar-\(Int(Date().timeIntervalSince1970 * 1000)).jpg"
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(filename)
        do {
            try data.write(to: url)
            await MainActor.run {
                SparkHaptics.lightImpact()
                avatar = SparkAvatarCatalog.encodePhoto(url.path)
                photoItem = nil
            }
        } catch {
            await MainActor.run {
                photoNote = "We couldn't save that photo. Try again. 💜"
            }
        }
    }

    private func openSettings() {
        #if canImport(UIKit)
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
        #endif
    }
}
