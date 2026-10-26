//
//  OpportunityDetailSheet.swift
//  Spark
//
//  Purpose:
//  Detailed opportunity sheet with external link actions.
//
//  Responsibilities:
//  • Shows full opportunity metadata and bookmark controls.
//

import SwiftUI

struct OpportunityDetailSheet: View {
    let opportunity: Opportunity
    let isSaved: Bool
    let onClose: () -> Void
    let onApply: () -> Void
    let onToggleSaved: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            headerSection

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    infoPills
                        .padding(.bottom, 18)

                    Text(opportunity.description)
                        .font(SparkTypography.font(.body, size: 16, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                        .lineSpacing(8)

                    VStack(spacing: 12) {
                        SparkPrimaryButton(
                            label: "Apply / Learn more",
                            gradient: LinearGradient(
                                colors: [SparkColors.lavender, SparkColors.primaryButtonGradientEnd],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            iconSystemName: "arrow.up.right.square",
                            action: onApply
                        )
                        .accessibilityLabel("Apply or learn more. Opens in in-app browser.")

                        saveButton
                    }
                    .padding(.top, 24)
                }
                .padding(22)
            }
            .scrollIndicators(.hidden)
        }
        .background(SparkColors.cream)
    }

    private var headerSection: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [opportunity.imageColor, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(SparkColors.ink)
                            .padding(6)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Circle())
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close")
                }

                Text(opportunity.category.rawValue.uppercased())
                    .font(SparkTypography.font(.bodyExtra, size: 12, relativeTo: .caption))
                    .foregroundStyle(SparkColors.white)
                    .padding(.top, 4)

                Text(opportunity.title)
                    .font(SparkTypography.font(.displayBold, size: 24, relativeTo: .title2))
                    .foregroundStyle(SparkColors.white)
                    .padding(.top, 4)

                Text(opportunity.org)
                    .font(SparkTypography.font(.body, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(SparkColors.white.opacity(0.95))
                    .padding(.top, 2)
            }
            .padding(.horizontal, 22)
            .padding(.top, 20)
            .padding(.bottom, 22)
        }
    }

    private var infoPills: some View {
        FlowLayout(spacing: 10, rowSpacing: 10) {
            infoPill(icon: "calendar", text: opportunity.deadline)
            infoPill(icon: "mappin.and.ellipse", text: opportunity.location)
            infoPill(icon: "sparkles", text: opportunity.cost.rawValue)
        }
    }

    private func infoPill(icon: String, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(SparkColors.lavender)
                .accessibilityHidden(true)
            Text(text)
                .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.ink)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(SparkColors.lavenderSoft)
        .clipShape(Capsule())
    }

    private var saveButton: some View {
        Button(action: onToggleSaved) {
            HStack(spacing: 8) {
                Image(systemName: isSaved ? "bookmark.fill" : "bookmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SparkColors.pink)
                Text(isSaved ? "Saved" : "Save for later")
                    .font(SparkTypography.font(.displayBold, size: 15, relativeTo: .body))
                    .foregroundStyle(SparkColors.pink)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(isSaved ? SparkColors.pinkSoft : SparkColors.white)
            .clipShape(Capsule())
            .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .frame(minHeight: 44)
        .accessibilityLabel(isSaved ? "Saved" : "Save for later")
    }
}

/// Flow layout that wraps info pills across multiple lines.
private struct FlowLayout: Layout {
    var spacing: CGFloat
    var rowSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, frame) in result.frames.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + frame.minX, y: bounds.minY + frame.minY),
                proposal: ProposedViewSize(frame.size)
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, frames: [CGRect]) {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var frames: [CGRect] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + rowSpacing
                rowHeight = 0
            }
            frames.append(CGRect(origin: CGPoint(x: x, y: y), size: size))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), frames)
    }
}
