//
//  BodyDoubleRowView.swift
//  Spark
//
//  Purpose:
//  Row UI for a scheduled body double session.
//
//  Responsibilities:
//  • Displays session details and participant actions.
//

import SwiftUI

struct BodyDoubleRowView: View {
    let post: BodyDoublePost
    let onJoin: () -> Void
    let onRemove: () -> Void

    private var isNeed: Bool {
        post.kind == .need
    }

    private var accent: Color {
        isNeed ? SparkColors.pink : SparkColors.mint
    }

    private var accentSoft: Color {
        isNeed ? SparkColors.pinkSoft : SparkColors.mintSoft
    }

    var body: some View {
        HStack(alignment: .top, spacing: SparkSpacing.sm) {
            AvatarView(avatarName: post.fromAvatar, size: 40)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: SparkSpacing.xs) {
                    Text(post.fromName)
                        .font(SparkTypography.font(.bodyExtra, size: 14, relativeTo: .subheadline))
                        .foregroundStyle(SparkColors.ink)

                    Text(isNeed ? "Needs company" : "Free to focus")
                        .font(SparkTypography.font(.bodyBold, size: 11, relativeTo: .caption2))
                        .foregroundStyle(accent)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(accentSoft)
                        .clipShape(Capsule())
                }
                .fixedSize(horizontal: false, vertical: true)

                if isNeed, let task = post.task {
                    Text(task)
                        .font(SparkTypography.font(.body, size: 14, relativeTo: .subheadline))
                        .foregroundStyle(SparkColors.ink)
                        .lineSpacing(5)
                        .padding(.top, 4)
                }

                if let when = post.when {
                    HStack(spacing: 5) {
                        Image(systemName: "clock")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(SparkColors.inkSoft)
                            .accessibilityHidden(true)
                        Text(when)
                            .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                            .foregroundStyle(SparkColors.inkSoft)
                    }
                    .padding(.top, 4)
                }

                if let note = post.note {
                    Text(note)
                        .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.inkSoft)
                        .lineSpacing(5)
                        .padding(.top, 4)
                }

                if post.mine {
                    Button(action: onRemove) {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                                .font(.system(size: 14, weight: .semibold))
                            Text("Remove")
                                .font(SparkTypography.font(.bodyBold, size: 12, relativeTo: .caption))
                        }
                        .foregroundStyle(SparkColors.inkSoft)
                        .padding(.horizontal, SparkSpacing.sm)
                        .padding(.vertical, 7)
                        .background(SparkColors.card)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                    .frame(minHeight: SparkSpacing.minimumTouchTarget, alignment: .leading)
                    .accessibilityLabel("Remove body double post")
                } else {
                    Button(action: onJoin) {
                        HStack(spacing: 6) {
                            Image(systemName: "hands.clap.fill")
                                .font(.system(size: 14, weight: .semibold))
                            Text("I'm in 🙌")
                                .font(SparkTypography.font(.bodyBold, size: 12, relativeTo: .caption))
                        }
                        .foregroundStyle(SparkColors.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(isNeed ? SparkTheme.gradient(.pink) : SparkTheme.gradient(.garden))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.top, 10)
                    .frame(minHeight: SparkSpacing.minimumTouchTarget, alignment: .leading)
                    .accessibilityLabel("Join \(post.fromName)'s body double")
                }
            }
        }
        .padding(14)
        .background(SparkColors.cream)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
    }
}
