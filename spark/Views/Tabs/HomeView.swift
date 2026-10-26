//
//  HomeView.swift
//  Spark
//
//  Purpose:
//  Home tab dashboard screen.
//
//  Responsibilities:
//  • Shows greeting, stats, toolkit tiles, and upcoming items.
//  • Routes users to major features from quick actions.
//

import SwiftUI

struct HomeView: View {
    @Environment(AppProfileStore.self) private var profileStore
    @Environment(QuestStore.self) private var questStore
    @Environment(FocusStore.self) private var focusStore
    @Environment(DatesStore.self) private var datesStore
    @Environment(CycleStore.self) private var cycleStore
    @Environment(RemindersStore.self) private var remindersStore
    @Environment(\.sparkSkin) private var skin
    @Environment(AppNavigationCoordinator.self) private var navigation

    private var totalSparks: Int {
        questStore.questSparks + focusStore.sparksEarned
    }

    var body: some View {
        let upcoming = UpcomingAggregator.aggregateUpcoming(
            dates: datesStore.dates,
            quests: questStore.quests,
            cycleEntries: cycleStore.entries,
            reminders: remindersStore.reminders,
            averageCycleLength: cycleStore.averageCycleLength,
            limit: 3
        )

        ZStack(alignment: .top) {
            SparkColors.cream.ignoresSafeArea()

            skin.wash
                .frame(height: 260)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    statChipsSection
                    affirmationSection
                    upcomingSection(upcoming)
                    feelingsQuickTile
                    connectSection
                    toolkitSection
                    footerSection
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.bottom, 40)
            }
            .safeAreaPadding(.top, SparkSpacing.md)
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    private var headerSection: some View {
        HStack(alignment: .center, spacing: SparkSpacing.sm) {
            SparkLogoView(size: 54, isInteractive: true)

            VStack(alignment: .leading, spacing: 0) {
                Text("\(HomeContent.greeting())!")
                    .font(SparkTypography.body())
                    .fontWeight(.semibold)
                    .foregroundStyle(SparkColors.inkSoft)

                Text(profileStore.profile?.displayName ?? "friend")
                    .sparkTitle()
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                navigation.navigate(to: .profile)
            } label: {
                AvatarView(
                    avatarName: profileStore.profile?.avatarName ?? SparkAvatarCatalog.defaultAvatarName,
                    size: 58
                )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Open profile")
        }
        .sparkFadeInDown(delay: 0, duration: 0.4)
    }

    private var statChipsSection: some View {
        HStack(spacing: SparkSpacing.sm) {
            statChip(
                background: SparkColors.yellowSoft,
                icon: {
                    SparkleBadge(size: 22)
                },
                value: "\(totalSparks)",
                label: "Sparks earned"
            )

            statChip(
                background: SparkColors.skySoft,
                icon: {
                    Image(systemName: "timer")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(SparkColors.sky)
                },
                value: "\(focusStore.totalMinutes)",
                label: "Focus minutes"
            )
        }
        .padding(.top, 18)
        .sparkFadeInDown(delay: 0.08)
    }

    private func statChip<I: View>(
        background: Color,
        @ViewBuilder icon: () -> I,
        value: String,
        label: String
    ) -> some View {
        HStack(spacing: 10) {
            icon()
            VStack(alignment: .leading, spacing: 0) {
                Text(value)
                    .font(SparkTypography.statValue())
                    .foregroundStyle(SparkColors.ink)
                Text(label)
                    .sparkCaption()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .padding(.horizontal, SparkSpacing.md)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
        .sparkSoftShadow()
    }

    private var affirmationSection: some View {
        Button {
            navigation.navigate(to: .learn)
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: SparkSpacing.xs) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SparkColors.white)
                    Text("TODAY'S SPARK")
                        .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.white)
                }

                Text(HomeContent.affirmation())
                    .font(SparkTypography.statValue())
                    .foregroundStyle(SparkColors.white)
                    .lineSpacing(8)
                    .padding(.top, 10)

                HStack(spacing: SparkSpacing.xxs) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(SparkColors.white)
                    Text("Visit your Neurodiversity Corner")
                        .font(SparkTypography.accentLink())
                        .foregroundStyle(SparkColors.white.opacity(0.95))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(SparkColors.white)
                }
                .padding(.top, 14)
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(skin.gradient)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
            .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .padding(.top, 18)
        .sparkFadeInDown(delay: 0.14)
        .accessibilityLabel("Today's Spark")
    }

    @ViewBuilder
    private func upcomingSection(_ upcoming: [UpcomingItem]) -> some View {
        if !upcoming.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    HStack(spacing: SparkSpacing.xs) {
                        Image(systemName: "bell.badge.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(SparkColors.lavender)
                        Text("Coming up")
                            .font(SparkTypography.sectionTitle())
                            .foregroundStyle(SparkColors.ink)
                    }

                    Spacer()

                    Button {
                        navigation.navigate(to: .reminders)
                    } label: {
                        HStack(spacing: 2) {
                            Text("See all")
                                .sparkAccentLink()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(SparkColors.lavender)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .padding(.bottom, 10)

                SparkCard {
                    VStack(spacing: 0) {
                        ForEach(Array(upcoming.enumerated()), id: \.element.id) { index, item in
                            if index > 0 {
                                Divider()
                                    .overlay(SparkColors.divider)
                            }

                            Button {
                                navigation.navigate(to: item.route)
                            } label: {
                                HStack(spacing: SparkSpacing.sm) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                                            .fill(SparkColors.lavenderSoft)
                                            .frame(width: 40, height: 40)
                                        Text(item.emoji)
                                            .font(.system(size: 20))
                                    }

                                    Text(item.title)
                                        .font(SparkTypography.body())
                                        .fontWeight(.semibold)
                                        .foregroundStyle(SparkColors.ink)
                                        .lineLimit(1)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    Text(UpcomingAggregator.whenLabel(item.when))
                                        .font(SparkTypography.accentLink())
                                        .foregroundStyle(SparkColors.lavender)
                                }
                                .padding(.vertical, 10)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.top, 20)
            .sparkFadeInDown(delay: 0.17)
        }
    }

    private var feelingsQuickTile: some View {
        Button {
            navigation.navigate(to: .feelings)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "face.smiling")
                    .font(.system(size: 30, weight: .regular))
                    .foregroundStyle(SparkColors.ink)

                VStack(alignment: .leading, spacing: 1) {
                    Text("How are you feeling today?")
                        .font(SparkTypography.font(.displayBold, size: 17, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                    Text("Take a quick, kind check-in 💗")
                        .font(SparkTypography.supportive())
                        .foregroundStyle(SparkColors.ink.opacity(0.75))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(SparkColors.ink)
            }
            .padding(SparkSpacing.lg)
            .background(
                LinearGradient(
                    colors: [Color(sparkHex: 0xD9F2D0), Color(sparkHex: 0xB7E4A8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
            .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .padding(.top, SparkSpacing.md)
        .sparkFadeInDown(delay: 0.2)
    }

    private var connectSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Connect & explore")
                .font(SparkTypography.sectionTitle())
                .foregroundStyle(SparkColors.ink)
                .padding(.top, 28)
                .padding(.bottom, 14)

            ForEach(Array(HomeContent.quickCards.enumerated()), id: \.element.id) { index, card in
                SparkPressableCard(action: { navigation.navigate(to: card.route) }) {
                    HStack(spacing: 14) {
                        gradientIconBox(
                            size: 52,
                            radius: SparkRadius.md,
                            gradient: SparkTheme.gradient(card.gradient),
                            icon: card.icon,
                            iconSize: 22
                        )

                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.title)
                                .font(SparkTypography.font(.displayBold, size: 17, relativeTo: .body))
                                .foregroundStyle(SparkColors.ink)
                            Text(card.subtitle)
                                .font(SparkTypography.font(.body, size: 14, relativeTo: .subheadline))
                                .foregroundStyle(SparkColors.inkSoft)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "chevron.right")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(SparkColors.inkSoft)
                    }
                }
                .padding(.bottom, 14)
                .sparkFadeInDown(delay: 0.24 + Double(index) * 0.09)
            }
        }
    }

    private var toolkitSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Your toolkit")
                .font(SparkTypography.sectionTitle())
                .foregroundStyle(SparkColors.ink)
                .padding(.top, SparkSpacing.md)
                .padding(.bottom, 14)

            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: SparkSpacing.sm), GridItem(.flexible(), spacing: SparkSpacing.sm)],
                spacing: SparkSpacing.sm
            ) {
                ForEach(Array(HomeContent.epicTiles.enumerated()), id: \.element.id) { index, tile in
                    Button {
                        navigation.navigate(to: tile.route)
                    } label: {
                        HStack(spacing: SparkSpacing.sm) {
                            gradientIconBox(
                                size: 38,
                                radius: SparkRadius.sm,
                                gradient: SparkTheme.gradient(tile.gradient),
                                icon: tile.icon,
                                iconSize: 18,
                                filled: tile.filledIcon
                            )

                            Text(tile.title)
                                .font(SparkTypography.font(.displayBold, size: 15, relativeTo: .body))
                                .foregroundStyle(SparkColors.ink)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 14)
                        .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
                        .background(HomeContent.toolkitWashColor(for: tile.gradient))
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                        .sparkSoftShadow()
                    }
                    .buttonStyle(.plain)
                    .sparkFadeInDown(delay: 0.42 + Double(index) * 0.06)
                }
            }
        }
    }

    private var footerSection: some View {
        SparkCard(backgroundColor: SparkColors.mintSoft) {
            VStack(alignment: .leading, spacing: 6) {
                Text("GENTLE REMINDER")
                    .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                    .foregroundStyle(SparkColors.mint)
                Text("Tiny steps still count. Showing up today is already a win. 🌈")
                    .font(SparkTypography.body())
                    .foregroundStyle(SparkColors.ink)
                    .lineSpacing(7)
            }
        }
        .padding(.top, SparkSpacing.xs)
        .sparkFadeInDown(delay: 0.64)
    }

    private func gradientIconBox(
        size: CGFloat,
        radius: CGFloat,
        gradient: LinearGradient,
        icon: String,
        iconSize: CGFloat,
        filled: Bool = false
    ) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(gradient)
                .frame(width: size, height: size)
            Image(systemName: icon)
                .font(.system(size: iconSize, weight: .semibold))
                .symbolVariant(filled ? .fill : .none)
                .foregroundStyle(SparkColors.white)
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
    .environment(AppProfileStore())
    .environment(QuestStore())
    .environment(FocusStore())
    .environment(DatesStore())
    .environment(CycleStore())
    .environment(RemindersStore())
    .environment(AppNavigationCoordinator())
    .environment(\.sparkSkin, SparkSkinCatalog.defaultSkin)
    .preferredColorScheme(.light)
}
