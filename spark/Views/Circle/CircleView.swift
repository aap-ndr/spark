//
//  CircleView.swift
//  Spark
//
//  Purpose:
//  Spark Circle overview screen.
//
//  Responsibilities:
//  • Lists circles, sparks, body doubles, and shared quests.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct CircleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CircleStore.self) private var circleStore
    @Environment(AppProfileStore.self) private var profileStore
    @Environment(AppNavigationCoordinator.self) private var navigation
    @State private var createOpen = false
    @State private var selectedDetail: CircleDestination?

    var body: some View {
        landingContent
            .navigationDestination(item: $selectedDetail) { destination in
                CircleDetailView(circleID: destination.circleID)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $createOpen) {
                CreateCircleSheet(
                    onClose: { createOpen = false },
                    onCreate: { name, emoji in
                        let me = SparkCircleMember.me(from: profileStore.profile)
                        let circle = circleStore.createCircle(name: name, emoji: emoji, me: me)
                        createOpen = false
                        openCircleDetail(circleID: circle.id)
                    },
                    onJoin: { code in
                        let me = SparkCircleMember.me(from: profileStore.profile)
                        if let circle = circleStore.joinCircle(code: code, me: me) {
                            createOpen = false
                            openCircleDetail(circleID: circle.id)
                        }
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
    }

    private var landingContent: some View {
        ZStack(alignment: .top) {
            SparkColors.cream.ignoresSafeArea()

            LinearGradient(
                colors: [SparkColors.pinkSoft, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)
            .accessibilityHidden(true)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    safetyBanner
                    createButton
                    circlesSection
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.bottom, 40)
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .safeAreaPadding(.top, SparkSpacing.md)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button {
                    SparkHaptics.lightImpact()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(SparkColors.inkSoft)
                        Text("Home")
                            .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                            .foregroundStyle(SparkColors.inkSoft)
                    }
                    .frame(minHeight: SparkSpacing.minimumTouchTarget, alignment: .leading)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back to Home")

                Spacer()

                HeaderShortcutsView(color: SparkColors.pink, hideCircles: true) { route in
                    navigation.homePath.append(route)
                }
            }

            Text("Spark Circle")
                .sparkTitle()
                .padding(.top, 10)

            Text("Your private, invite-only support squad 💗")
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 4)
        }
        .sparkFadeInDown(duration: 0.4)
    }

    private var safetyBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(SparkColors.mint)
                .accessibilityHidden(true)
            Text(CircleContent.safetyBanner)
                .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.ink)
                .lineSpacing(5)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(SparkColors.mintSoft)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
        .padding(.top, SparkSpacing.lg)
        .sparkFadeInDown(delay: 0.06)
    }

    private var createButton: some View {
        Button {
            SparkHaptics.lightImpact()
            createOpen = true
        } label: {
            HStack(spacing: SparkSpacing.sm) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 44, height: 44)
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(SparkColors.white)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Create or join a circle")
                        .font(SparkTypography.font(.displayBold, size: 17, relativeTo: .body))
                        .foregroundStyle(SparkColors.white)
                    Text("Invite your most trusted friends")
                        .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.white.opacity(0.9))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(SparkSpacing.cardPadding)
            .background(SparkTheme.gradient(.lavender))
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
            .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .padding(.top, SparkSpacing.lg)
        .accessibilityLabel("Create or join a circle")
        .sparkFadeInDown(delay: 0.1)
    }

    @ViewBuilder
    private var circlesSection: some View {
        if !circleStore.circles.isEmpty {
            Text("Your circles")
                .font(SparkTypography.sectionTitle())
                .foregroundStyle(SparkColors.ink)
                .padding(.top, 26)
                .padding(.bottom, SparkSpacing.sm)

            ForEach(Array(circleStore.circles.enumerated()), id: \.element.id) { index, circle in
                circleRow(circle)
                    .padding(.bottom, 14)
                    .sparkFadeInDown(delay: 0.14 + Double(index) * 0.08)
            }
        }
    }

    private func circleRow(_ circle: SparkCircle) -> some View {
        Button {
            openCircleDetail(circleID: circle.id)
        } label: {
            circleRowContent(circle)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(circle.name), \(circle.members.count) members")
    }

    private func circleRowContent(_ circle: SparkCircle) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                    .fill(SparkColors.lavenderSoft)
                    .frame(width: 52, height: 52)
                Text(circle.emoji)
                    .font(.system(size: 26))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(circle.name)
                    .font(SparkTypography.font(.displayBold, size: 17, relativeTo: .body))
                    .foregroundStyle(SparkColors.ink)
                HStack(spacing: 6) {
                    Image(systemName: "person.2.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(SparkColors.inkSoft)
                        .accessibilityHidden(true)
                    Text("\(circle.members.count) members")
                        .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.inkSoft)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: -10) {
                ForEach(Array(circle.members.prefix(3).enumerated()), id: \.element.id) { _, member in
                    AvatarView(avatarName: member.avatarName, size: 32)
                }
            }
        }
        .padding(SparkSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SparkColors.card)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
        .sparkSoftShadow()
    }

    private func openCircleDetail(circleID: String) {
        selectedDetail = CircleDestination(circleID: circleID)
    }
}

extension SparkCircleMember {
    static func me(from profile: UserProfile?) -> SparkCircleMember {
        SparkCircleMember(
            id: profile?.id ?? "me",
            displayName: profile?.displayName ?? "You",
            avatarName: profile?.avatarName ?? SparkAvatarCatalog.defaultAvatarName
        )
    }
}

#Preview {
    HomeNavigationView()
        .environment(CircleStore())
        .environment(AppProfileStore())
        .environment(AppNavigationCoordinator())
}
