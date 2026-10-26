//
//  UnsavedChangesGuard.swift
//  Spark
//
//  Purpose:
//  Shared helpers for draft tracking and guarded dismissal.
//
//  Responsibilities:
//  • Compares normalized drafts to detect unsaved edits.
//  • Provides reusable discard alerts and dismiss guards.
//

import SwiftUI

enum UnsavedChangesGuard {
    static let discardTitle = "Discard changes?"

    static func profileMessage() -> String {
        "You have unsaved profile changes."
    }

    static func avatarBuilderMessage() -> String {
        "You have unsaved avatar changes."
    }

    static func formMessage(_ formName: String) -> String {
        "You have unsaved \(formName) changes."
    }
}

struct NormalizedProfileDraft: Equatable {
    let displayName: String
    let avatarName: String
    let bio: String?
    let likes: String?
    let dislikes: String?

    static func from(profile: UserProfile?) -> NormalizedProfileDraft {
        normalize(
            displayName: profile?.displayName ?? "",
            avatarName: profile?.avatarName ?? SparkAvatarCatalog.defaultAvatarName,
            bio: profile?.bio ?? "",
            likes: profile?.likes ?? "",
            dislikes: profile?.dislikes ?? ""
        )
    }

    static func normalize(
        displayName: String,
        avatarName: String,
        bio: String,
        likes: String,
        dislikes: String
    ) -> NormalizedProfileDraft {
        NormalizedProfileDraft(
            displayName: displayName.trimmingCharacters(in: .whitespacesAndNewlines),
            avatarName: SparkAvatarCatalog.normalizeAvatarName(avatarName),
            bio: optionalText(bio),
            likes: optionalText(likes),
            dislikes: optionalText(dislikes)
        )
    }

    private static func optionalText(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

extension View {
    func discardChangesAlert(
        isPresented: Binding<Bool>,
        message: String,
        onDiscard: @escaping () -> Void
    ) -> some View {
        alert(UnsavedChangesGuard.discardTitle, isPresented: isPresented) {
            Button("Keep editing", role: .cancel) {}
            Button("Discard changes", role: .destructive, action: onDiscard)
        } message: {
            Text(message)
        }
    }

    func unsavedChangesDismissDisabled(_ isDirty: Bool) -> some View {
        interactiveDismissDisabled(isDirty)
    }
}
