//
//  AppTourView.swift
//  Spark
//
//  Purpose:
//  In-app walkthrough of Spark's main areas.
//
//  Responsibilities:
//  • Presents multi-slide tour content with skip and completion actions.
//

import SwiftUI

/// In-app walkthrough of Spark's main areas, presented from the profile tab.
struct AppTourView: View {
    let onClose: () -> Void

    @State private var index = 0

    private struct Slide: Identifiable {
        let id: Int
        let emoji: String
        let title: String
        let body: String
        let gradient: LinearGradient
        let usesLogo: Bool
    }

    private let slides: [Slide] = [
        Slide(id: 0, emoji: "🌟", title: "Welcome to Spark!", body: "Your cozy little home for focus, feelings and friends — built for brains like yours. Let's take a quick peek at what's inside.", gradient: SparkTheme.gradient(.dream), usesLogo: true),
        Slide(id: 1, emoji: "✅", title: "Quests", body: "Turn big goals into tiny, doable steps. Check them off to earn Sparks and watch your progress grow.", gradient: SparkTheme.gradient(.sunrise), usesLogo: false),
        Slide(id: 2, emoji: "😊", title: "Feelings", body: "Check in with how you feel — no wrong answers. Track your moods over the week and find calming tools.", gradient: SparkTheme.gradient(.garden), usesLogo: false),
        Slide(id: 3, emoji: "🎂", title: "Events", body: "Save birthdays, exams and special moments — I'll gently remind you before they arrive.", gradient: SparkTheme.gradient(.twilight), usesLogo: false),
        Slide(id: 4, emoji: "💗", title: "Spark Circles", body: "Send warm little sparks of encouragement to your trusted friends, and share your quests with them.", gradient: SparkTheme.gradient(.pink), usesLogo: false),
        Slide(id: 5, emoji: "🔍", title: "Find My Things", body: "Put something down and forget where? Save where your phone, keys or glasses are so you can find them later.", gradient: SparkTheme.gradient(.mint), usesLogo: false),
        Slide(id: 6, emoji: "🔔", title: "Reminders", body: "Set gentle recurring nudges — take medicine, drink water, call someone you love — daily or on certain days.", gradient: SparkTheme.gradient(.ocean), usesLogo: false),
        Slide(id: 7, emoji: "🧭", title: "Discover Opportunities", body: "Explore camps, clubs and chances to shine — handpicked places to try new things and grow.", gradient: SparkTheme.gradient(.sunrise), usesLogo: false),
        Slide(id: 8, emoji: "🧠", title: "Learn about ADHD", body: "Understand ADHD and neurodiversity in a warm, strengths-based way — all about how your beautiful brain works.", gradient: SparkTheme.gradient(.coral), usesLogo: false),
        Slide(id: 9, emoji: "🎨", title: "Your Profile", body: "Make it yours — build your avatar, pick a vibe, and share a bit about you. You can replay this tour here anytime!", gradient: SparkTheme.gradient(.berry), usesLogo: false),
    ]

    private var isLast: Bool { index == slides.count - 1 }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            SparkColors.cream.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $index) {
                    ForEach(slides) { slide in
                        slideView(slide)
                            .tag(slide.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                HStack(spacing: 7) {
                    ForEach(slides) { slide in
                        Capsule()
                            .fill(slide.id == index ? SparkColors.lavender : SparkColors.lavenderSoft)
                            .frame(width: slide.id == index ? 22 : 8, height: 8)
                            .onTapGesture { index = slide.id }
                    }
                }
                .padding(.bottom, 20)

                SparkPrimaryButton(
                    label: isLast ? "Let's go!" : "Next",
                    gradient: SparkTheme.gradient(.dream),
                    iconSystemName: isLast ? "checkmark" : "chevron.right",
                    action: next
                )
                .padding(.horizontal, SparkSpacing.section)
                .padding(.bottom, 24)
            }

            if !isLast {
                Button(action: skip) {
                    HStack(spacing: 4) {
                        Text("Skip")
                            .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                            .foregroundStyle(SparkColors.inkSoft)
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(SparkColors.inkSoft)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(SparkColors.card)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 12)
                .padding(.trailing, 16)
                .zIndex(1)
            }
        }
    }

    private func slideView(_ slide: Slide) -> some View {
        VStack(spacing: 0) {
            if slide.usesLogo {
                SparkLogoView(size: 124, isInteractive: false)
                    .frame(width: 150, height: 150)
                    .background(SparkColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: 44, style: .continuous))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 44, style: .continuous)
                        .fill(slide.gradient)
                        .frame(width: 150, height: 150)
                    Text(slide.emoji)
                        .font(.system(size: 72))
                }
            }

            Text(slide.title)
                .font(SparkTypography.font(.displayBold, size: 26, relativeTo: .title2))
                .foregroundStyle(SparkColors.ink)
                .multilineTextAlignment(.center)
                .padding(.top, 34)

            Text(slide.body)
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.inkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(8)
                .padding(.horizontal, 32)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }

    private func next() {
        SparkHaptics.lightImpact()
        if isLast {
            onClose()
        } else {
            index += 1
        }
    }

    private func skip() {
        SparkHaptics.lightImpact()
        onClose()
    }
}
