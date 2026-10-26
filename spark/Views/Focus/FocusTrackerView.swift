//
//  FocusTrackerView.swift
//  Spark
//
//  Purpose:
//  Focus session history and stats view.
//
//  Responsibilities:
//  • Summarizes recorded focus activity over time.
//

import SwiftUI

struct FocusTrackerView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(FocusStore.self) private var focusStore

    private var recentSessions: [FocusSession] {
        Array(focusStore.sessions.prefix(12))
    }

    var body: some View {
        ZStack {
            SparkColors.cream.ignoresSafeArea()

            LinearGradient(
                colors: [SparkColors.skySoft, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        SparkHaptics.lightImpact()
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(SparkColors.inkSoft)
                            Text("Focus")
                                .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                                .foregroundStyle(SparkColors.inkSoft)
                        }
                        .frame(minHeight: 44, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Back to Focus")

                    Text("Your focus tracker")
                        .sparkTitle()
                        .padding(.top, 10)
                    Text("Every minute you show up adds up. 🌟")
                        .font(SparkTypography.body())
                        .foregroundStyle(SparkColors.inkSoft)
                        .lineSpacing(6)
                        .padding(.top, 2)

                    statTiles
                        .padding(.top, 22)

                    Text("Recent sessions")
                        .font(SparkTypography.sectionTitle())
                        .foregroundStyle(SparkColors.ink)
                        .padding(.top, 28)

                    if recentSessions.isEmpty {
                        emptyState
                            .padding(.top, 14)
                    } else {
                        VStack(spacing: 10) {
                            ForEach(recentSessions) { session in
                                sessionRow(session)
                            }
                        }
                        .padding(.top, 14)
                    }
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.bottom, 60)
            }
            .safeAreaPadding(.top, SparkSpacing.md)
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }

    private var statTiles: some View {
        HStack(spacing: 10) {
            statTile(
                label: "Minutes focused",
                value: focusStore.totalMinutes,
                background: SparkColors.skySoft,
                icon: "timer",
                iconColor: SparkColors.sky
            )
            statTile(
                label: "Sessions",
                value: focusStore.sessionsCompleted,
                background: SparkColors.peachSoft,
                icon: "flame.fill",
                iconColor: SparkColors.peach
            )
            statTile(
                label: "Sparks earned",
                value: focusStore.sparksEarned,
                background: SparkColors.yellowSoft,
                icon: "sparkles",
                iconColor: SparkColors.yellow
            )
        }
    }

    private func statTile(
        label: String,
        value: Int,
        background: Color,
        icon: String,
        iconColor: Color
    ) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(iconColor)
            Text("\(value)")
                .font(SparkTypography.font(.displayBold, size: 22, relativeTo: .title2))
                .foregroundStyle(SparkColors.ink)
            Text(label)
                .font(SparkTypography.font(.body, size: 11, relativeTo: .caption2))
                .foregroundStyle(SparkColors.inkSoft)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SparkSpacing.md)
        .padding(.horizontal, SparkSpacing.sm)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
        .sparkSoftShadow()
    }

    private var emptyState: some View {
        Text("No focus sessions yet. Head back and start a realm to see your progress bloom here. 🌱")
            .font(SparkTypography.font(.body, size: 14, relativeTo: .subheadline))
            .foregroundStyle(SparkColors.inkSoft)
            .multilineTextAlignment(.center)
            .lineSpacing(7)
            .padding(SparkSpacing.cardPadding)
            .frame(maxWidth: .infinity)
            .background(SparkColors.lavenderSoft)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
            .sparkSoftShadow()
    }

    private func sessionRow(_ session: FocusSession) -> some View {
        HStack(spacing: SparkSpacing.sm) {
            ZStack {
                RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous)
                    .fill(SparkTheme.gradient(.ocean))
                    .frame(width: 44, height: 44)
                Image(systemName: "timer")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(SparkColors.white)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(session.realmName ?? "Focus session")
                    .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                    .foregroundStyle(SparkColors.ink)
                    .lineLimit(1)
                Text("\(session.minutes) min · \(UpcomingAggregator.whenLabel(session.completedAt))")
                    .font(SparkTypography.supportive())
                    .foregroundStyle(SparkColors.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(SparkSpacing.cardPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SparkColors.card)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
        .sparkSoftShadow()
    }
}

#Preview {
    NavigationStack {
        FocusTrackerView()
    }
    .environment(FocusStore())
}
