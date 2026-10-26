//
//  CircleDetailView.swift
//  Spark
//
//  Purpose:
//  Detailed view for a single Spark Circle.
//
//  Responsibilities:
//  • Shows members, activity, sparks, and shared quests for one circle.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct CircleDetailView: View {
    let circleID: String

    @Environment(\.dismiss) private var dismiss
    @Environment(CircleStore.self) private var circleStore
    @Environment(QuestStore.self) private var questStore
    @Environment(AppProfileStore.self) private var profileStore
    @Environment(AppNavigationCoordinator.self) private var navigation

    @State private var composerOpen = false
    @State private var bodyDoubleKind: BodyDoubleKind?
    @State private var sparkDraft = ""
    @State private var copiedCode = false

    private var circle: SparkCircle? {
        circleStore.circle(id: circleID)
    }

    private var thread: [SparkMessage] {
        circleStore.messages(for: circleID)
    }

    private var sharedQuests: [Quest] {
        questStore.quests.filter { $0.circleIds?.contains(circleID) == true }
    }

    private var bodyDoubles: [BodyDoublePost] {
        circleStore.bodyDoubles(for: circleID)
    }

    private var me: SparkCircleMember {
        SparkCircleMember.me(from: profileStore.profile)
    }

    var body: some View {
        Group {
            if let circle {
                detailContent(circle)
            } else {
                missingCircleView
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    @ViewBuilder
    private func detailContent(_ circle: SparkCircle) -> some View {
        ZStack(alignment: .bottom) {
            SparkColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                headerSection(circle)

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        inviteCard(circle)
                        sharedQuestsSection
                        bodyDoubleSection(circle)
                        sparkThreadSection
                    }
                    .padding(SparkSpacing.cardPadding)
                    .padding(.bottom, 120)
                }
                .scrollIndicators(.hidden)
            }

            sendSparkBar
        }
        .sheet(isPresented: $composerOpen) {
            SparkComposerSheet(
                draft: $sparkDraft,
                onClose: { composerOpen = false },
                onSend: { text in
                    handleSendSpark(text, circleID: circle.id)
                }
            )
        }
        .sheet(item: $bodyDoubleKind) { kind in
            BodyDoubleComposerSheet(
                kind: kind,
                onClose: { bodyDoubleKind = nil },
                onSubmit: { kind, task, when, note in
                    handlePostBodyDouble(kind: kind, task: task, when: when, note: note, circleID: circle.id)
                }
            )
        }
    }

    private var missingCircleView: some View {
        VStack(spacing: SparkSpacing.md) {
            Text("Circle not found")
                .font(SparkTypography.sectionTitle())
            Button("Go back") { dismiss() }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(SparkColors.cream)
    }

    private func headerSection(_ circle: SparkCircle) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: SparkSpacing.sm) {
                Button {
                    SparkHaptics.lightImpact()
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(SparkColors.white)
                        .frame(width: 34, height: 34)
                        .background(Color.white.opacity(0.4))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back to circles")

                VStack(alignment: .leading, spacing: 2) {
                    Text("\(circle.emoji) \(circle.name)")
                        .font(SparkTypography.font(.displayBold, size: 20, relativeTo: .title3))
                        .foregroundStyle(SparkColors.white)
                    Text("\(circle.members.count) members · code \(circle.inviteCode)")
                        .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: -12) {
                ForEach(Array(circle.members.prefix(6).enumerated()), id: \.element.id) { index, member in
                    AvatarView(avatarName: member.avatarName, size: 40)
                        .zIndex(Double(6 - index))
                }
            }
            .padding(.leading, 6)
            .padding(.top, 14)
        }
        .padding(.horizontal, SparkSpacing.cardPadding)
        .padding(.top, SparkSpacing.sm)
        .padding(.bottom, 18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SparkTheme.gradient(.dream))
    }

    private func inviteCard(_ circle: SparkCircle) -> some View {
        SparkCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                            .fill(SparkColors.pinkSoft)
                            .frame(width: 40, height: 40)
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(SparkColors.pink)
                            .accessibilityHidden(true)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Invite your friends")
                            .font(SparkTypography.font(.displayBold, size: 16, relativeTo: .body))
                            .foregroundStyle(SparkColors.ink)
                        Text("Share code ")
                            .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                            .foregroundStyle(SparkColors.inkSoft)
                        + Text(circle.inviteCode)
                            .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                            .foregroundColor(SparkColors.lavender)
                        + Text(" with someone you trust 💗")
                            .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                            .foregroundStyle(SparkColors.inkSoft)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack(spacing: 10) {
                    ShareLink(item: CircleContent.inviteMessage(circleName: circle.name, inviteCode: circle.inviteCode)) {
                        HStack(spacing: SparkSpacing.xs) {
                            Image(systemName: "paperplane.fill")
                                .font(.system(size: 17, weight: .semibold))
                            Text("Invite friends")
                                .font(SparkTypography.font(.displayBold, size: 15, relativeTo: .body))
                        }
                        .foregroundStyle(SparkColors.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 13)
                        .background(SparkTheme.gradient(.pink))
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                    }
                    .simultaneousGesture(TapGesture().onEnded {
                        SparkHaptics.lightImpact()
                    })
                    .accessibilityLabel("Invite friends, opens share sheet")

                    Button(action: { copyCode(circle.inviteCode) }) {
                        HStack(spacing: 7) {
                            Image(systemName: copiedCode ? "checkmark" : "doc.on.doc")
                                .font(.system(size: 17, weight: .semibold))
                            Text(copiedCode ? "Copied!" : "Copy code")
                                .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                        }
                        .foregroundStyle(copiedCode ? SparkColors.mint : SparkColors.lavender)
                        .padding(.horizontal, SparkSpacing.md)
                        .frame(minHeight: 44)
                        .background(copiedCode ? SparkColors.mintSoft : SparkColors.lavenderSoft)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(copiedCode ? "Code copied" : "Copy invite code")
                }
                .padding(.top, 14)
            }
        }
        .padding(.bottom, SparkSpacing.lg)
    }

    @ViewBuilder
    private var sharedQuestsSection: some View {
        if !sharedQuests.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: SparkSpacing.xs) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SparkColors.lavender)
                        .accessibilityHidden(true)
                    Text("Shared quests")
                        .font(SparkTypography.font(.displayBold, size: 17, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                    if sharedQuests.count > 1 {
                        Text("· swipe to see all")
                            .font(SparkTypography.font(.body, size: 12, relativeTo: .caption))
                            .foregroundStyle(SparkColors.inkSoft)
                    }
                }
                .padding(.bottom, 10)

                if sharedQuests.count == 1, let quest = sharedQuests.first {
                    SharedQuestCardView(quest: quest) {
                        navigation.navigate(to: .quests)
                    }
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: SparkSpacing.sm) {
                            ForEach(sharedQuests) { quest in
                                SharedQuestCardView(quest: quest) {
                                    navigation.navigate(to: .quests)
                                }
                                .frame(width: 300)
                            }
                        }
                    }
                }
            }
            .padding(.bottom, SparkSpacing.lg)
        }
    }

    private func bodyDoubleSection(_ circle: SparkCircle) -> some View {
        SparkCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                            .fill(SparkColors.mintSoft)
                            .frame(width: 40, height: 40)
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(SparkColors.mint)
                            .accessibilityHidden(true)
                    }

                    VStack(alignment: .leading, spacing: 1) {
                        Text("Body doubling")
                            .font(SparkTypography.font(.displayBold, size: 16, relativeTo: .body))
                            .foregroundStyle(SparkColors.ink)
                        Text("Work alongside a friend — company makes focus easier. 💪")
                            .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                            .foregroundStyle(SparkColors.inkSoft)
                            .lineSpacing(5)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack(spacing: 10) {
                    bodyDoubleActionButton(
                        title: "Need a body double",
                        icon: "hands.clap.fill",
                        foreground: SparkColors.pink,
                        background: SparkColors.pinkSoft
                    ) {
                        SparkHaptics.lightImpact()
                        bodyDoubleKind = .need
                    }

                    bodyDoubleActionButton(
                        title: "I'm free",
                        icon: "person.2.fill",
                        foreground: SparkColors.mint,
                        background: SparkColors.mintSoft
                    ) {
                        SparkHaptics.lightImpact()
                        bodyDoubleKind = .free
                    }
                }
                .padding(.top, 14)

                if bodyDoubles.isEmpty {
                    Text("No body-double posts yet. Be the first to ask for company\nor offer to focus together 💗")
                        .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.inkSoft)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .frame(maxWidth: .infinity)
                        .padding(14)
                        .background(SparkColors.cream)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        .padding(.top, 14)
                } else {
                    VStack(spacing: 10) {
                        ForEach(bodyDoubles) { post in
                            BodyDoubleRowView(
                                post: post,
                                onJoin: { handleJoinBodyDouble(post) },
                                onRemove: { handleRemoveBodyDouble(post.id) }
                            )
                        }
                    }
                    .padding(.top, 14)
                }
            }
        }
        .padding(.bottom, SparkSpacing.lg)
    }

    @ViewBuilder
    private var sparkThreadSection: some View {
        if thread.isEmpty {
            VStack(spacing: 0) {
                Image(systemName: "sparkles")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(SparkColors.lavender)
                    .accessibilityHidden(true)
                Text("No Sparks yet")
                    .font(SparkTypography.sectionTitle())
                    .foregroundStyle(SparkColors.ink)
                    .padding(.top, SparkSpacing.sm)
                Text("Send the first warm message to brighten\nsomeone's day 💗")
                    .font(SparkTypography.font(.body, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(SparkColors.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.top, 6)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 40)
        } else {
            ForEach(thread) { message in
                sparkBubble(message)
                    .padding(.bottom, 14)
            }
        }
    }

    private var sendSparkBar: some View {
        VStack(spacing: 0) {
            SparkPrimaryButton(
                label: "Send a Spark",
                gradient: SparkTheme.gradient(.pink),
                iconSystemName: "sparkles",
                iconFilled: true,
                action: { composerOpen = true }
            )
            .padding(.horizontal, SparkSpacing.cardPadding)
            .padding(.top, 10)
            .padding(.bottom, SparkSpacing.sm)
        }
        .background(SparkColors.cream)
    }

    private func bodyDoubleActionButton(
        title: String,
        icon: String,
        foreground: Color,
        background: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 7) {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .semibold))
                Text(title)
                    .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 13)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }

    private func sparkBubble(_ message: SparkMessage) -> some View {
        HStack(alignment: .bottom, spacing: SparkSpacing.xs) {
            if message.direction == .outgoing {
                Spacer(minLength: 0)
            }

            if message.direction == .incoming {
                AvatarView(avatarName: message.fromAvatar, size: 36)
            }

            VStack(alignment: .leading, spacing: 3) {
                if message.direction == .incoming {
                    Text(message.fromName)
                        .font(SparkTypography.font(.bodyExtra, size: 12, relativeTo: .caption))
                        .foregroundStyle(SparkColors.lavender)
                }

                Text(message.text)
                    .font(SparkTypography.body())
                    .foregroundStyle(message.direction == .outgoing ? SparkColors.white : SparkColors.ink)
                    .lineSpacing(6)
            }
            .padding(14)
            .frame(maxWidth: UIScreenWidth.value * 0.76, alignment: .leading)
            .background(message.direction == .outgoing ? SparkColors.lavender : SparkColors.card)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: SparkRadius.lg,
                    bottomLeadingRadius: message.direction == .incoming ? 6 : SparkRadius.lg,
                    bottomTrailingRadius: message.direction == .outgoing ? 6 : SparkRadius.lg,
                    topTrailingRadius: SparkRadius.lg,
                    style: .continuous
                )
            )
            .sparkSoftShadow()

            if message.direction == .incoming {
                Spacer(minLength: 0)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityLabel(for: message))
    }

    private func accessibilityLabel(for message: SparkMessage) -> String {
        switch message.direction {
        case .incoming:
            return "\(message.fromName) says \(message.text)"
        case .outgoing:
            return "You sent \(message.text)"
        }
    }

    private func copyCode(_ code: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = code
        #endif
        SparkHaptics.successNotification()
        copiedCode = true
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            await MainActor.run {
                copiedCode = false
            }
        }
    }

    private func handleSendSpark(_ text: String, circleID: String) {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        SparkHaptics.successNotification()
        circleStore.sendSpark(circleID: circleID, text: text, me: me)
        sparkDraft = ""
        composerOpen = false
        scheduleDemoReply(circleID: circleID)
    }

    private func scheduleDemoReply(circleID: String) {
        let reply = CircleContent.randomAutoReply()
        Task {
            try? await Task.sleep(nanoseconds: 1_400_000_000)
            await MainActor.run {
                circleStore.receiveDemoSpark(circleID: circleID, text: reply)
            }
        }
    }

    private func handlePostBodyDouble(
        kind: BodyDoubleKind,
        task: String?,
        when: String?,
        note: String?,
        circleID: String
    ) {
        SparkHaptics.successNotification()
        circleStore.postBodyDouble(
            circleID: circleID,
            kind: kind,
            task: task,
            when: when,
            note: note,
            me: me
        )
        bodyDoubleKind = nil
    }

    private func handleJoinBodyDouble(_ post: BodyDoublePost) {
        SparkHaptics.successNotification()
        let text: String
        if post.kind == .need {
            text = "Count me in for body doubling — \(post.task ?? "let's focus together")! 🙌"
        } else if let when = post.when {
            text = "I'm in! Let's body double \(when) — company makes focus easier 💪"
        } else {
            text = "I'm in! Let's body double — company makes focus easier 💪"
        }
        circleStore.sendSpark(circleID: circleID, text: text, me: me)
        scheduleDemoReply(circleID: circleID)
    }

    private func handleRemoveBodyDouble(_ id: String) {
        SparkHaptics.mediumImpact()
        circleStore.removeBodyDouble(id: id)
    }
}

private enum UIScreenWidth {
    static var value: CGFloat {
        #if canImport(UIKit)
        UIScreen.main.bounds.width
        #else
        390
        #endif
    }
}

extension BodyDoubleKind: Identifiable {
    var id: String { rawValue }
}

#Preview {
    NavigationStack {
        CircleDetailView(circleID: "demo")
    }
    .environment(CircleStore())
    .environment(QuestStore())
    .environment(AppProfileStore())
    .environment(AppNavigationCoordinator())
}
