//
//  AvatarBuilderView.swift
//  Spark
//
//  Purpose:
//  Full-screen DiceBear Avataaars builder.
//
//  Responsibilities:
//  • Lets users customize and preview profile avatars before saving.
//

import SwiftUI

/// Full-screen DiceBear Avataaars builder for profile avatars.
struct AvatarBuilderView: View {
    let initial: AvatarConfig
    let gradient: LinearGradient
    let onSave: (String) -> Void
    let onCancel: () -> Void

    @State private var config: AvatarConfig
    @State private var showDiscardAlert = false

    private var hasUnsavedChanges: Bool {
        config != initial
    }

    init(
        initial: AvatarConfig,
        gradient: LinearGradient,
        onSave: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.initial = initial
        self.gradient = gradient
        self.onSave = onSave
        self.onCancel = onCancel
        _config = State(initialValue: initial)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            SparkColors.cream.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header
                    preview
                    optionSection("SKIN TONE") {
                        ForEach(SparkAvatarCatalog.skinTones, id: \.self) { hex in
                            colorChip(hex: hex, selected: config.skinColor == hex) {
                                config.skinColor = hex
                            }
                        }
                    }
                    optionSection("HAIRSTYLE") {
                        ForEach(SparkAvatarCatalog.hairstyles, id: \.self) { style in
                            thumbButton(
                                cfg: AvatarConfig(
                                    skinColor: config.skinColor,
                                    top: style,
                                    covering: nil,
                                    hairColor: config.hairColor,
                                    accessory: nil,
                                    clothesColor: config.clothesColor,
                                    backgroundColor: "f2ecff"
                                ),
                                selected: config.covering == nil && config.top == style
                            ) {
                                config.top = style
                                config.covering = nil
                            }
                        }
                    }
                    if config.covering == nil {
                        optionSection("HAIR COLOR") {
                            ForEach(SparkAvatarCatalog.hairColors, id: \.self) { hex in
                                colorChip(hex: hex, selected: config.hairColor == hex) {
                                    config.hairColor = hex
                                }
                            }
                        }
                    }
                    optionSection("HEAD COVERING") {
                        nonePill(selected: config.covering == nil) {
                            config.covering = nil
                        }
                        ForEach(SparkAvatarCatalog.coverings.compactMap { $0 }, id: \.self) { covering in
                            thumbButton(
                                cfg: AvatarConfig(
                                    skinColor: config.skinColor,
                                    top: config.top,
                                    covering: covering,
                                    hairColor: config.hairColor,
                                    accessory: nil,
                                    clothesColor: config.clothesColor,
                                    backgroundColor: "f2ecff"
                                ),
                                selected: config.covering == covering,
                                label: SparkAvatarCatalog.coveringLabel(covering)
                            ) {
                                config.covering = covering
                            }
                        }
                    }
                    optionSection("GLASSES") {
                        nonePill(selected: config.accessory == nil) {
                            config.accessory = nil
                        }
                        ForEach(SparkAvatarCatalog.accessories.compactMap { $0 }, id: \.self) { accessory in
                            thumbButton(
                                cfg: AvatarConfig(
                                    skinColor: config.skinColor,
                                    top: config.top,
                                    covering: config.covering,
                                    hairColor: config.hairColor,
                                    accessory: accessory,
                                    clothesColor: config.clothesColor,
                                    backgroundColor: "f2ecff"
                                ),
                                selected: config.accessory == accessory,
                                label: SparkAvatarCatalog.accessoryLabel(accessory)
                            ) {
                                config.accessory = accessory
                            }
                        }
                    }
                    optionSection("TOP COLOR") {
                        ForEach(SparkAvatarCatalog.clothesColors, id: \.self) { hex in
                            colorChip(hex: hex, selected: config.clothesColor == hex) {
                                config.clothesColor = hex
                            }
                        }
                    }
                    optionSection("BACKGROUND") {
                        ForEach(SparkAvatarCatalog.backgroundColors, id: \.self) { hex in
                            colorChip(hex: hex, selected: config.backgroundColor == hex, transparentLabel: hex == "transparent") {
                                config.backgroundColor = hex
                            }
                        }
                    }
                }
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)

            saveBar
        }
        .discardChangesAlert(
            isPresented: $showDiscardAlert,
            message: UnsavedChangesGuard.avatarBuilderMessage(),
            onDiscard: onCancel
        )
    }

    private var header: some View {
        HStack {
            Button(action: requestCancel) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SparkColors.ink)
                    .frame(width: 38, height: 38)
                    .background(SparkColors.card)
                    .clipShape(Circle())
                    .sparkSoftShadow()
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Cancel avatar design")

            Spacer()

            Text("Design your avatar")
                .font(SparkTypography.font(.displayBold, size: 18, relativeTo: .body))
                .foregroundStyle(SparkColors.ink)

            Spacer()

            Color.clear.frame(width: 38, height: 38)
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
    }

    private var preview: some View {
        ZStack {
            Circle()
                .fill(SparkColors.white)
                .frame(width: 172, height: 172)
                .sparkAvatarShadow()

            AvatarConfigImage(config: config, pixelSize: 320)
                .frame(width: 160, height: 160)
                .clipShape(Circle())
        }
        .padding(.top, 14)
        .frame(maxWidth: .infinity)
        .padding(.bottom, 8)
    }

    private var saveBar: some View {
        VStack(spacing: 0) {
            Divider().overlay(Color.black.opacity(0.05))
            SparkPrimaryButton(
                label: "Save avatar",
                gradient: gradient,
                showsSparkleIcon: true,
                action: {
                    SparkHaptics.successNotification()
                    onSave(SparkAvatarCatalog.encode(config))
                }
            )
            .padding(.horizontal, SparkSpacing.xxl)
            .padding(.top, 14)
            .padding(.bottom, 14)
        }
        .background(SparkColors.cream)
    }

    private func optionSection<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(title)
                .font(SparkTypography.font(.bodyExtra, size: 12, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.horizontal, SparkSpacing.xxl)
                .padding(.top, 22)
                .padding(.bottom, 10)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    content()
                }
                .padding(.horizontal, SparkSpacing.xxl)
            }
        }
    }

    private func colorChip(hex: String, selected: Bool, transparentLabel: Bool = false, action: @escaping () -> Void) -> some View {
        Button {
            SparkHaptics.lightImpact()
            action()
        } label: {
            ZStack {
                if transparentLabel {
                    Circle()
                        .fill(SparkColors.card)
                        .overlay {
                            Text("None")
                                .font(SparkTypography.font(.bodyBold, size: 11, relativeTo: .caption2))
                                .foregroundStyle(SparkColors.inkSoft)
                        }
                } else {
                    Circle()
                        .fill(Color(sparkHex: UInt(hex, radix: 16) ?? 0))
                }
            }
            .frame(width: 46, height: 46)
            .overlay {
                Circle()
                    .strokeBorder(selected ? SparkColors.lavender : Color.black.opacity(0.08), lineWidth: selected ? 3 : 1)
            }
            .overlay {
                if selected && !transparentLabel {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(SparkColors.lavender)
                        .padding(4)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(transparentLabel ? "No background" : "Color option")
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func nonePill(selected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            SparkHaptics.lightImpact()
            action()
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(SparkColors.card)
                        .frame(width: 64, height: 64)
                        .overlay {
                            Circle()
                                .strokeBorder(selected ? SparkColors.lavender : Color.black.opacity(0.08), lineWidth: selected ? 3 : 1.5)
                        }
                    Image(systemName: "xmark")
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(selected ? SparkColors.lavender : SparkColors.inkSoft)
                }
                Text("None")
                    .font(SparkTypography.font(selected ? .bodyBold : .body, size: 11, relativeTo: .caption2))
                    .foregroundStyle(selected ? SparkColors.lavender : SparkColors.inkSoft)
            }
            .frame(width: 66)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func thumbButton(cfg: AvatarConfig, selected: Bool, label: String? = nil, action: @escaping () -> Void) -> some View {
        Button {
            SparkHaptics.lightImpact()
            action()
        } label: {
            VStack(spacing: 5) {
                ZStack {
                    Circle()
                        .fill(SparkColors.white)
                        .frame(width: 64, height: 64)

                    AvatarConfigImage(config: cfg, pixelSize: 128)
                        .frame(width: selected ? 52 : 58, height: selected ? 52 : 58)
                        .clipShape(Circle())
                }
                .overlay {
                    Circle()
                        .strokeBorder(selected ? SparkColors.lavender : Color.clear, lineWidth: 3)
                        .padding(1)
                }

                if let label {
                    Text(label)
                        .font(SparkTypography.font(selected ? .bodyBold : .body, size: 11, relativeTo: .caption2))
                        .foregroundStyle(selected ? SparkColors.lavender : SparkColors.inkSoft)
                        .lineLimit(1)
                }
            }
            .frame(width: 66)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }

    private func requestCancel() {
        if hasUnsavedChanges {
            showDiscardAlert = true
        } else {
            onCancel()
        }
    }
}
