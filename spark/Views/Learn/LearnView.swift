//
//  LearnView.swift
//  Spark
//
//  Purpose:
//  Neurodiversity Corner learning screen.
//
//  Responsibilities:
//  • Presents educational sections and external resource links.
//

import SwiftUI

struct LearnView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppNavigationCoordinator.self) private var navigation
    @State private var safariDestination: SafariDestination?

    var body: some View {
        ZStack(alignment: .top) {
            SparkColors.cream.ignoresSafeArea()

            LinearGradient(
                colors: [SparkColors.skySoft, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)
            .accessibilityHidden(true)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    whatIsADHDSection
                    strengthsSection
                    girlsSection
                    coOccurringSection
                    resourcesSection
                    disclaimerSection
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.bottom, 60)
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .safeAreaPadding(.top, SparkSpacing.sm)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $safariDestination) { destination in
            SafariView(url: destination.url)
                .ignoresSafeArea()
        }
    }

    // MARK: - Header

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

                HeaderShortcutsView(color: SparkColors.sky) { route in
                    navigation.homePath.append(route)
                }
            }

            HStack(spacing: 10) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 28, weight: .regular))
                    .foregroundStyle(SparkColors.lavender)
                    .accessibilityHidden(true)

                Text("Neurodiversity Corner")
                    .sparkTitle()
            }
            .padding(.top, 10)

            Text(LearnContent.headerSubtitle)
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.inkSoft)
                .lineSpacing(6)
                .padding(.top, 4)
        }
        .sparkFadeInDown(duration: 0.4)
    }

    // MARK: - What is ADHD?

    private var whatIsADHDSection: some View {
        SparkCard {
            VStack(alignment: .leading, spacing: 0) {
                sectionHeader(emoji: "🧠", title: "What is ADHD?")

                Text(LearnContent.whatIsADHDIntro)
                    .font(SparkTypography.body())
                    .foregroundStyle(SparkColors.ink)
                    .lineSpacing(8)
                    .padding(.top, 10)

                (
                    Text(LearnContent.whatIsADHDBodyPrefix)
                    + Text(LearnContent.whatIsADHDBodyBold)
                        .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                    + Text(LearnContent.whatIsADHDBodySuffix)
                )
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.ink)
                .lineSpacing(8)
                .padding(.top, 10)
            }
        }
        .padding(.top, SparkSpacing.xl)
        .sparkFadeInDown(delay: 0.08)
    }

    // MARK: - Strengths

    private var strengthsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: SparkSpacing.xs) {
                Image(systemName: "sparkles")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(SparkColors.white)
                    .accessibilityHidden(true)
                Text("Your brain, your strengths")
                    .font(SparkTypography.sectionTitle())
                    .foregroundStyle(SparkColors.white)
            }

            Text(LearnContent.strengthIntro)
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.white.opacity(0.97))
                .lineSpacing(8)
                .padding(.top, 10)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(LearnContent.strengthItems, id: \.self) { item in
                    Text(item)
                        .font(SparkTypography.body())
                        .foregroundStyle(SparkColors.white)
                        .lineSpacing(7)
                }
            }
            .padding(.top, 10)

            Text(LearnContent.strengthFooter)
                .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                .foregroundStyle(SparkColors.white)
                .lineSpacing(7)
                .padding(.top, 14)
        }
        .padding(SparkSpacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SparkTheme.gradient(.dream))
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
        .sparkSoftShadow()
        .padding(.top, 14)
        .sparkFadeInDown(delay: 0.14)
    }

    // MARK: - Girls

    private var girlsSection: some View {
        SparkCard {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: SparkSpacing.xs) {
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(SparkColors.pink)
                        .accessibilityHidden(true)
                    Text("How it can look in girls")
                        .font(SparkTypography.sectionTitle())
                        .foregroundStyle(SparkColors.ink)
                }

                Text(LearnContent.girlsIntro)
                    .font(SparkTypography.body())
                    .foregroundStyle(SparkColors.ink)
                    .lineSpacing(8)
                    .padding(.top, 10)

                ForEach(LearnContent.girlsBullets, id: \.self) { bullet in
                    LearnBulletRow(text: bullet)
                }

                Text(LearnContent.girlsFooter)
                    .font(SparkTypography.body())
                    .foregroundStyle(SparkColors.ink)
                    .lineSpacing(8)
                    .padding(.top, SparkSpacing.sm)
            }
        }
        .padding(.top, 14)
        .sparkFadeInDown(delay: 0.2)
    }

    // MARK: - Co-occurring

    private var coOccurringSection: some View {
        SparkCard {
            VStack(alignment: .leading, spacing: 0) {
                sectionHeader(emoji: "🧩", title: "You might have other differences too — and that's okay")

                Text(LearnContent.coOccurringIntro)
                    .font(SparkTypography.body())
                    .foregroundStyle(SparkColors.ink)
                    .lineSpacing(8)
                    .padding(.top, 10)

                ForEach(LearnContent.coOccurringBullets, id: \.self) { bullet in
                    LearnBulletRow(text: bullet)
                }

                Text(LearnContent.coOccurringFooter)
                    .font(SparkTypography.body())
                    .foregroundStyle(SparkColors.ink)
                    .lineSpacing(8)
                    .padding(.top, SparkSpacing.sm)
            }
        }
        .padding(.top, 14)
        .sparkFadeInDown(delay: 0.26)
    }

    // MARK: - Resources

    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: SparkSpacing.xs) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SparkColors.pink)
                    .accessibilityHidden(true)
                Text("Helpful resources")
                    .font(SparkTypography.sectionTitle())
                    .foregroundStyle(SparkColors.ink)
            }
            .padding(.top, 26)

            Text(LearnContent.resourcesSectionSubtitle)
                .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .lineSpacing(5)
                .padding(.top, 4)
                .padding(.bottom, SparkSpacing.sm)

            ForEach(LearnContent.resources) { resource in
                resourceCard(resource)
                    .padding(.bottom, SparkSpacing.sm)
            }
        }
        .sparkFadeInDown(delay: 0.32)
    }

    private func resourceCard(_ resource: LearnContent.Resource) -> some View {
        Group {
            if let destination = SafariDestination(urlString: resource.url) {
                SparkPressableCard {
                    openResource(destination)
                } content: {
                    resourceCardContent(resource)
                }
                .accessibilityLabel("\(resource.name). \(resource.desc). Opens in in-app browser.")
            } else {
                resourceCardContent(resource)
                    .padding(SparkSpacing.cardPadding)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(SparkColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
                    .sparkSoftShadow()
                    .opacity(0.45)
                    .accessibilityLabel("\(resource.name). \(resource.desc). Link unavailable.")
            }
        }
    }

    private func resourceCardContent(_ resource: LearnContent.Resource) -> some View {
        HStack(spacing: SparkSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                    .fill(SparkColors.skySoft)
                    .frame(width: 46, height: 46)
                Text(resource.emoji)
                    .font(.system(size: 22))
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(resource.name)
                    .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                    .foregroundStyle(SparkColors.ink)
                Text(resource.desc)
                    .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                    .foregroundStyle(SparkColors.inkSoft)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Image(systemName: "arrow.up.right.square")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(SparkColors.lavender)
                .accessibilityHidden(true)
        }
    }

    // MARK: - Disclaimer

    private var disclaimerSection: some View {
        Text(LearnContent.disclaimer)
            .font(SparkTypography.font(.body, size: 12, relativeTo: .caption))
            .foregroundStyle(SparkColors.inkSoft)
            .lineSpacing(6)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(SparkColors.lavenderSoft)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
            .padding(.top, 10)
    }

    // MARK: - Helpers

    private func sectionHeader(emoji: String, title: String) -> some View {
        HStack(spacing: SparkSpacing.xs) {
            Text(emoji)
                .font(.system(size: 20))
                .accessibilityHidden(true)
            Text(title)
                .font(SparkTypography.sectionTitle())
                .foregroundStyle(SparkColors.ink)
        }
    }

    private func openResource(_ destination: SafariDestination) {
        SparkHaptics.lightImpact()
        safariDestination = destination
    }
}

private struct LearnBulletRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: SparkSpacing.xs) {
            Text("•")
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.lavender)
                .padding(.top, 1)
                .accessibilityHidden(true)
            Text(text)
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.ink)
                .lineSpacing(7)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, SparkSpacing.xs)
    }
}

#Preview {
    NavigationStack {
        LearnView()
    }
    .environment(AppNavigationCoordinator())
    .preferredColorScheme(.light)
}
