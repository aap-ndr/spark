//
//  SparkTypography.swift
//  Spark
//
//  Purpose:
//  Semantic typography styles built on SF Pro.
//
//  Responsibilities:
//  • Maps font roles to size and weight combinations.
//  • Exposes reusable Text view modifiers for common styles.
//

import SwiftUI

/// Semantic text styles built on SF Pro with fixed sizes for the Spark hierarchy.
enum SparkTypography {
    enum Role {
        case display
        case displayBold
        case heading
        case body
        case bodyBold
        case bodyExtra
    }

    static func font(_ role: Role, size: CGFloat, relativeTo _: Font.TextStyle = .body) -> Font {
        .system(size: size, weight: weight(for: role), design: .default)
    }

    static func largeTitle() -> Font {
        font(.displayBold, size: 30, relativeTo: .largeTitle)
    }

    static func title() -> Font {
        font(.displayBold, size: 28, relativeTo: .title)
    }

    static func sectionTitle() -> Font {
        font(.displayBold, size: 18, relativeTo: .title3)
    }

    static func body() -> Font {
        font(.body, size: 15, relativeTo: .body)
    }

    static func bodyLarge() -> Font {
        font(.body, size: 16, relativeTo: .body)
    }

    static func supportive() -> Font {
        font(.body, size: 13, relativeTo: .subheadline)
    }

    static func caption() -> Font {
        font(.body, size: 12, relativeTo: .caption)
    }

    static func button() -> Font {
        font(.displayBold, size: 17, relativeTo: .body)
    }

    /// Small bold lavender links for tappable secondary actions.
    static func accentLink() -> Font {
        font(.bodyBold, size: 13, relativeTo: .footnote)
    }

    static func fieldLabel() -> Font {
        font(.bodyBold, size: 14, relativeTo: .subheadline)
    }

    static func fieldInput() -> Font {
        font(.bodyBold, size: 17, relativeTo: .body)
    }

    static func welcomeBadge() -> Font {
        font(.displayBold, size: 16, relativeTo: .callout)
    }

    static func statValue() -> Font {
        font(.displayBold, size: 20, relativeTo: .title3)
    }

    private static func weight(for role: Role) -> Font.Weight {
        switch role {
        case .display, .bodyBold:
            return .semibold
        case .displayBold, .bodyExtra:
            return .bold
        case .heading:
            return .medium
        case .body:
            return .regular
        }
    }
}

extension Text {
    func sparkLargeTitle() -> some View {
        font(SparkTypography.largeTitle())
            .foregroundStyle(SparkColors.ink)
    }

    func sparkTitle() -> some View {
        font(SparkTypography.title())
            .foregroundStyle(SparkColors.ink)
    }

    func sparkSectionTitle() -> some View {
        font(SparkTypography.sectionTitle())
            .foregroundStyle(SparkColors.ink)
    }

    func sparkBody() -> some View {
        font(SparkTypography.body())
            .foregroundStyle(SparkColors.ink)
    }

    func sparkBodyLarge() -> some View {
        font(SparkTypography.bodyLarge())
            .foregroundStyle(SparkColors.inkSoft)
    }

    func sparkSupportive() -> some View {
        font(SparkTypography.supportive())
            .foregroundStyle(SparkColors.inkSoft)
    }

    func sparkCaption() -> some View {
        font(SparkTypography.caption())
            .foregroundStyle(SparkColors.inkSoft)
    }

    func sparkAccentLink() -> some View {
        font(SparkTypography.accentLink())
            .foregroundStyle(SparkColors.lavender)
    }
}
