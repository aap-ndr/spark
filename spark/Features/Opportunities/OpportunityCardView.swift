//
//  OpportunityCardView.swift
//  Spark
//
//  Purpose:
//  Opportunity list card UI.
//
//  Responsibilities:
//  • Displays opportunity summary, category, and save action.
//

import SwiftUI

struct OpportunityCardView: View {
    let opportunity: Opportunity
    let isSaved: Bool
    let onOpenDetail: () -> Void
    let onToggleSaved: () -> Void
    let onCheckItOut: () -> Void

    private var costStyle: OpportunityCostStyle {
        OpportunityCostStyle.style(for: opportunity.cost)
    }

    var body: some View {
        VStack(spacing: 0) {
            opportunity.imageColor
                .frame(height: 6)

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .top, spacing: 10) {
                    Button(action: onOpenDetail) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text(opportunity.category.rawValue.uppercased())
                                .font(SparkTypography.font(.bodyExtra, size: 11, relativeTo: .caption2))
                                .foregroundStyle(opportunity.imageColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(SparkColors.cream)
                                .clipShape(Capsule())
                                .padding(.bottom, 8)

                            Text(opportunity.title)
                                .font(SparkTypography.font(.displayBold, size: 17, relativeTo: .body))
                                .foregroundStyle(SparkColors.ink)
                                .multilineTextAlignment(.leading)

                            Text(opportunity.org)
                                .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                                .foregroundStyle(SparkColors.inkSoft)
                                .padding(.top, 2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(opportunity.title), \(opportunity.org)")
                    .accessibilityHint("Opens opportunity details")

                    Button(action: onToggleSaved) {
                        Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(isSaved ? SparkColors.pink : SparkColors.inkSoft)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isSaved ? "Remove bookmark" : "Save for later")
                    .accessibilityValue(isSaved ? "Saved" : "Not saved")
                }

                Button(action: onOpenDetail) {
                    HStack(spacing: 14) {
                        HStack(spacing: 5) {
                            Image(systemName: "mappin.and.ellipse")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(SparkColors.inkSoft)
                            Text(opportunity.location)
                                .font(SparkTypography.font(.body, size: 12, relativeTo: .caption))
                                .foregroundStyle(SparkColors.inkSoft)
                        }

                        Text(opportunity.cost.rawValue)
                            .font(SparkTypography.font(.bodyBold, size: 11, relativeTo: .caption2))
                            .foregroundStyle(costStyle.foreground)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 3)
                            .background(costStyle.background)
                            .clipShape(Capsule())
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)
                .padding(.top, 12)

                Button(action: onCheckItOut) {
                    HStack(spacing: 7) {
                        Image(systemName: "arrow.up.right.square")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Check it out")
                            .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                    }
                    .foregroundStyle(SparkColors.lavender)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
                    .background(SparkColors.lavenderSoft)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 14)
                .frame(minHeight: 44)
                .accessibilityLabel("Check it out, \(opportunity.title). Opens in in-app browser.")
            }
            .padding(16)
        }
        .background(SparkColors.card)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
        .sparkSoftShadow()
    }
}
