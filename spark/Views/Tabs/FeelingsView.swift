//
//  FeelingsView.swift
//  Spark
//
//  Purpose:
//  Feelings tab screen and feel-better toolkit entry points.
//
//  Responsibilities:
//  • Hosts mood check-ins, tracker history, and supportive tools.
//

import SwiftUI

private enum FeelingsDestination: Hashable {
    case tracker
}

struct FeelingsView: View {
    @Environment(FeelingsStore.self) private var feelingsStore

    @State private var selectedMoods: Set<String> = []
    @State private var sheetOpen = false
    @State private var breatheOpen = false
    @State private var groundOpen = false
    @State private var affirmationIndex = 0
    @State private var supportResponse: SupportiveResponse?
    @State private var supportDismissTask: Task<Void, Never>?
    @State private var navigationPath = NavigationPath()

    private var selectedFeelings: [FeelingOption] {
        FeelingsContent.feelings.filter { selectedMoods.contains($0.mood) }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            feelingsContent
                .navigationDestination(for: FeelingsDestination.self) { destination in
                    switch destination {
                    case .tracker:
                        FeelingsTrackerView()
                    }
                }
                .navigationDestination(for: AppRoute.self) { route in
                    AppRouteDestination(route: route)
                }
        }
    }

    private var feelingsContent: some View {
        ZStack(alignment: .top) {
            SparkColors.cream.ignoresSafeArea()

            LinearGradient(
                colors: [SparkColors.pinkSoft, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 280)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    if let supportResponse {
                        supportBanner(supportResponse)
                    }
                    moodPickerSection
                    toolkitSection
                    supportFooterSection
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.bottom, 60)
            }
            .safeAreaPadding(.top, SparkSpacing.md)
            .scrollIndicators(.hidden)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $sheetOpen) {
            FeelingsCheckInSheet(
                feelings: selectedFeelings,
                onClose: { sheetOpen = false },
                onSave: saveCheckIn
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .fullScreenCover(isPresented: $breatheOpen) {
            BreathingModalView { breatheOpen = false }
        }
        .fullScreenCover(isPresented: $groundOpen) {
            GroundingModalView { groundOpen = false }
        }
        .onDisappear {
            supportDismissTask?.cancel()
        }
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Feelings Navigator")
                    .sparkTitle()
                Text("Check in with yourself. No wrong answers. 💗")
                    .font(SparkTypography.body())
                    .foregroundStyle(SparkColors.inkSoft)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 10) {
                Button {
                    SparkHaptics.lightImpact()
                    navigationPath.append(FeelingsDestination.tracker)
                } label: {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(SparkColors.pink)
                        .frame(width: 44, height: 44)
                        .background(SparkColors.card)
                        .clipShape(Capsule())
                        .sparkSoftShadow()
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open feelings tracker")

                HeaderShortcutsView(color: SparkColors.pink) { route in
                    navigationPath.append(route)
                }
            }
        }
        .sparkFadeInDown(duration: 0.4)
    }

    private func supportBanner(_ response: SupportiveResponse) -> some View {
        let gradient: SparkGradientPreset = response.tone == .down ? .dream : .garden
        let heading = response.tone == .down ? "A LITTLE NOTE FOR YOU" : "LOVE THIS FOR YOU"

        return VStack(alignment: .leading, spacing: SparkSpacing.xs) {
            HStack(spacing: SparkSpacing.xs) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(SparkColors.white)
                Text(heading)
                    .font(SparkTypography.font(.bodyExtra, size: 12, relativeTo: .caption))
                    .foregroundStyle(SparkColors.white)
            }

            Text(response.message)
                .font(SparkTypography.font(.displayBold, size: 17, relativeTo: .body))
                .foregroundStyle(SparkColors.white)
                .lineSpacing(8)
        }
        .padding(SparkSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(SparkTheme.gradient(gradient))
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
        .sparkSoftShadow()
        .padding(.top, SparkSpacing.md)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(heading). \(response.message)")
    }

    private var moodPickerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("How are you feeling?")
                .sparkSectionTitle()
                .padding(.top, SparkSpacing.section)

            Text("Pick as many as fit — you can feel more than one thing. 💗")
                .font(SparkTypography.supportive())
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 2)

            FeelingsFlowLayout(spacing: SparkSpacing.xs, rowSpacing: SparkSpacing.xs) {
                ForEach(FeelingsContent.feelings) { feeling in
                    moodChip(feeling)
                }
            }
            .padding(.top, 14)

            SparkPrimaryButton(
                label: selectedMoods.count > 1 ? "Log \(selectedMoods.count) feelings" : "Log how I feel",
                gradient: SparkTheme.gradient(.pink),
                isEnabled: !selectedMoods.isEmpty,
                iconSystemName: "checkmark",
                action: openCheckInSheet
            )
            .padding(.top, SparkSpacing.md)
        }
        .sparkFadeInDown(delay: 0.1)
    }

    private func moodChip(_ feeling: FeelingOption) -> some View {
        let active = selectedMoods.contains(feeling.mood)

        return Button {
            SparkHaptics.lightImpact()
            if active {
                selectedMoods.remove(feeling.mood)
            } else {
                selectedMoods.insert(feeling.mood)
            }
        } label: {
            HStack(spacing: 6) {
                Text(feeling.emoji)
                    .font(.system(size: 18))
                Text(feeling.mood)
                    .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(active ? SparkColors.white : SparkColors.ink)
                if active {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(SparkColors.white)
                }
            }
            .padding(.leading, SparkSpacing.sm)
            .padding(.trailing, active ? 10 : SparkSpacing.sm)
            .padding(.vertical, 9)
            .background(active ? SparkColors.pink : feeling.color)
            .clipShape(Capsule())
            .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(feeling.mood)
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    private var toolkitSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Feel-better toolkit")
                .sparkSectionTitle()
                .padding(.top, SparkSpacing.sectionTop)

            SparkPressableCard(action: { breatheOpen = true }) {
                toolkitRow(
                    gradient: .ocean,
                    systemImage: "wind",
                    title: "Box breathing",
                    subtitle: "Breathe in 4, hold 4, out 4 🫧"
                )
            }
            .padding(.top, 14)
            .accessibilityLabel("Box breathing. Breathe in 4, hold 4, out 4")

            SparkPressableCard(action: { groundOpen = true }) {
                toolkitRow(
                    gradient: .garden,
                    systemImage: "anchor.fill",
                    title: "5-4-3-2-1 grounding",
                    subtitle: "Come back to the present with your senses 🌿"
                )
            }
            .padding(.top, SparkSpacing.sm)
            .accessibilityLabel("5-4-3-2-1 grounding. Come back to the present with your senses")

            Button {
                SparkHaptics.lightImpact()
                affirmationIndex = (affirmationIndex + 1) % FeelingsContent.affirmations.count
            } label: {
                VStack(alignment: .leading, spacing: SparkSpacing.xs) {
                    HStack(spacing: SparkSpacing.xs) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16))
                            .foregroundStyle(SparkColors.white)
                        Text("GENTLE REFRAME · TAP FOR ANOTHER")
                            .font(SparkTypography.font(.bodyExtra, size: 12, relativeTo: .caption))
                            .foregroundStyle(SparkColors.white)
                    }

                    Text(FeelingsContent.affirmations[affirmationIndex])
                        .font(SparkTypography.font(.displayBold, size: 18, relativeTo: .title3))
                        .foregroundStyle(SparkColors.white)
                        .lineSpacing(8)
                }
                .padding(SparkSpacing.xl)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SparkTheme.gradient(.dream))
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
                .sparkSoftShadow()
            }
            .buttonStyle(.plain)
            .padding(.top, SparkSpacing.sm)
            .accessibilityLabel("Gentle reframe. \(FeelingsContent.affirmations[affirmationIndex]). Tap for another.")
        }
        .sparkFadeInDown(delay: 0.22)
    }

    private func toolkitRow(
        gradient: SparkGradientPreset,
        systemImage: String,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: systemImage)
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(SparkColors.white)
                .frame(width: 50, height: 50)
                .background(SparkTheme.gradient(gradient))
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(SparkTypography.font(.displayBold, size: 16, relativeTo: .body))
                    .foregroundStyle(SparkColors.ink)
                Text(subtitle)
                    .font(SparkTypography.supportive())
                    .foregroundStyle(SparkColors.inkSoft)
                    .lineLimit(2)
            }
        }
    }

    private var supportFooterSection: some View {
        SparkCard(backgroundColor: SparkColors.peachSoft) {
            Text("YOU DESERVE SUPPORT")
                .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.peach)

            Text("If your feelings ever get too heavy to carry alone, reaching out to a trusted adult — a parent, teacher, or school counselor — is a brave and smart thing to do. You never have to figure everything out by yourself. 💗")
                .font(SparkTypography.bodyLarge())
                .foregroundStyle(SparkColors.ink)
                .lineSpacing(8)
                .padding(.top, 6)
        }
        .padding(.top, SparkSpacing.xxl)
        .sparkFadeInDown(delay: 0.28)
    }

    private func openCheckInSheet() {
        guard !selectedFeelings.isEmpty else { return }
        SparkHaptics.mediumImpact()
        sheetOpen = true
    }

    private func saveCheckIn(intensity: Int, note: String?) {
        for feeling in selectedFeelings {
            feelingsStore.addEntry(
                mood: feeling.mood,
                emoji: feeling.emoji,
                intensity: intensity,
                note: note
            )
        }

        sheetOpen = false

        if let first = selectedFeelings.first {
            supportResponse = SupportiveResponseService.response(for: first.mood)
        }
        selectedMoods.removeAll()

        supportDismissTask?.cancel()
        supportDismissTask = Task {
            try? await Task.sleep(for: .seconds(7))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                supportResponse = nil
            }
        }
    }
}

private struct FeelingsFlowLayout: Layout {
    var spacing: CGFloat
    var rowSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for placement in result.placements {
            subviews[placement.index].place(
                at: CGPoint(x: bounds.minX + placement.origin.x, y: bounds.minY + placement.origin.y),
                proposal: .unspecified
            )
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> Arrangement {
        let maxWidth = proposal.width ?? .infinity
        var origin = CGPoint.zero
        var rowHeight: CGFloat = 0
        var size = CGSize.zero
        var placements: [Placement] = []

        for index in subviews.indices {
            let dimension = subviews[index].sizeThatFits(.unspecified)
            if origin.x > 0, origin.x + dimension.width > maxWidth {
                origin.x = 0
                origin.y += rowHeight + rowSpacing
                rowHeight = 0
            }

            placements.append(Placement(index: index, origin: origin))
            rowHeight = max(rowHeight, dimension.height)
            origin.x += dimension.width + spacing
            size.width = max(size.width, origin.x - spacing)
            size.height = max(size.height, origin.y + rowHeight)
        }

        return Arrangement(size: size, placements: placements)
    }

    private struct Placement {
        let index: Int
        let origin: CGPoint
    }

    private struct Arrangement {
        let size: CGSize
        let placements: [Placement]
    }
}

#Preview {
    FeelingsView()
        .environment(FeelingsStore())
}
