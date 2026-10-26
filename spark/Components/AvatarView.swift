//
//  AvatarView.swift
//  Spark
//
//  Purpose:
//  Profile avatar renderer with illustrated and fallback styles.
//
//  Responsibilities:
//  • Displays DiceBear avatars and preset images at configurable sizes.
//  • Handles loading, caching, and placeholder states.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

struct AvatarView: View {
    let avatarName: String
    var size: CGFloat = 56
    var showsRing: Bool = true

    private var normalizedName: String {
        SparkAvatarCatalog.normalizeAvatarName(avatarName)
    }

    var body: some View {
        Group {
            if let photoPath = SparkAvatarCatalog.photoURI(from: normalizedName) {
                PhotoAvatarView(filePath: photoPath, size: size, showsRing: showsRing)
            } else {
                IllustratedAvatarView(
                    avatarName: normalizedName,
                    size: size,
                    showsRing: showsRing
                )
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityLabel)
    }

    private var accessibilityLabel: String {
        if SparkAvatarCatalog.isPhotoAvatar(normalizedName) {
            return "Photo avatar"
        }
        if SparkAvatarCatalog.isCustomAvatar(normalizedName) {
            return "Illustrated avatar"
        }
        return "Avatar"
    }
}

private struct IllustratedAvatarView: View {
    let avatarName: String
    let size: CGFloat
    let showsRing: Bool

    private var config: AvatarConfig {
        SparkAvatarCatalog.resolvedConfig(for: avatarName)
    }

    private var softBackground: Color {
        SparkAvatarCatalog.placeholderColor(for: config)
    }

    var body: some View {
        AvatarFrame(size: size, showsRing: showsRing) { inner in
            if let url = SparkAvatarCatalog.url(for: config, size: Int(inner * 2)) {
                IllustratedAvatarImage(
                    url: url,
                    placeholderColor: softBackground,
                    showsPlaceholderIcon: true
                )
                .id(url.absoluteString)
                .frame(width: inner, height: inner)
                .clipShape(Circle())
            } else {
                avatarPlaceholder(inner: inner)
            }
        }
    }

    private func avatarPlaceholder(inner: CGFloat) -> some View {
        Circle()
            .fill(softBackground)
            .overlay {
                Image(systemName: "person.fill")
                    .font(.system(size: inner * 0.42, weight: .semibold))
                    .foregroundStyle(SparkColors.lavender.opacity(0.35))
            }
            .frame(width: inner, height: inner)
    }
}

private struct PhotoAvatarView: View {
    let filePath: String
    let size: CGFloat
    let showsRing: Bool

    var body: some View {
        AvatarFrame(size: size, showsRing: showsRing) { inner in
            if let image = loadImage() {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: inner, height: inner)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(SparkColors.lavenderSoft)
                    .overlay {
                        Image(systemName: "person.fill")
                            .font(.system(size: inner * 0.42, weight: .semibold))
                            .foregroundStyle(SparkColors.lavender.opacity(0.35))
                    }
                    .frame(width: inner, height: inner)
            }
        }
    }

    private func loadImage() -> UIImage? {
        #if canImport(UIKit)
        let url = URL(fileURLWithPath: filePath)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
        #else
        return nil
        #endif
    }
}

private enum AvatarRingColors {
    static let colors: [Color] = [
        Color(sparkHex: 0xFF5FA2),
        Color(sparkHex: 0xFF7A3D),
        Color(sparkHex: 0xFFD24D),
        Color(sparkHex: 0x5BC85E),
        Color(sparkHex: 0x3E9BFF),
        Color(sparkHex: 0x8A46E6),
        Color(sparkHex: 0xB5714A),
        Color(sparkHex: 0xFF5FA2),
    ]
}

private struct AvatarFrame<Content: View>: View {
    let size: CGFloat
    let showsRing: Bool
    @ViewBuilder let content: (CGFloat) -> Content

    private var ringWidth: CGFloat {
        showsRing ? max(3, size * 0.06) : 0
    }

    private var gap: CGFloat {
        showsRing ? max(1.5, size * 0.02) : 0
    }

    private var inner: CGFloat {
        size - (ringWidth + gap) * 2
    }

    private var whiteDiameter: CGFloat {
        size - ringWidth * 2
    }

    var body: some View {
        Group {
            if showsRing {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: AvatarRingColors.colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: size, height: size)

                    whiteGapContainer
                }
            } else {
                whiteGapContainer
            }
        }
        .frame(width: size, height: size)
        .sparkAvatarShadow()
    }

    private var whiteGapContainer: some View {
        ZStack {
            Circle()
                .fill(SparkColors.white)
                .frame(width: whiteDiameter, height: whiteDiameter)

            content(inner)
        }
    }
}

#Preview {
    HStack(spacing: SparkSpacing.md) {
        AvatarView(avatarName: SparkAvatarCatalog.defaultOnboardingAvatarName, showsRing: false)
        AvatarView(avatarName: SparkAvatarCatalog.defaultAvatarName)
        AvatarView(avatarName: "nova")
    }
    .padding()
    .background(SparkColors.cream)
}
