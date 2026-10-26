//
//  QuestsView.swift
//  Spark
//
//  Purpose:
//  Quests tab screen.
//
//  Responsibilities:
//  • Displays quest stats, creation entry point, and reorderable quest list.
//

import SwiftUI

struct QuestsView: View {
    @Environment(QuestStore.self) private var questStore
    @Environment(CircleStore.self) private var circleStore

    @State private var formOpen = false
    @State private var confettiBurst = 0
    @State private var navigationPath = NavigationPath()

    private var totalSparks: Int {
        questStore.questSparks
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            questsContent
                .navigationDestination(for: AppRoute.self) { route in
                    AppRouteDestination(route: route)
                }
        }
    }

    private var questsContent: some View {
        ZStack(alignment: .top) {
            SparkColors.cream.ignoresSafeArea()

            LinearGradient(
                colors: [SparkColors.yellowSoft, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    newQuestButton
                    emptyState
                    questList
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.bottom, 120)
            }
            .safeAreaPadding(.top, SparkSpacing.md)
            .scrollIndicators(.hidden)

            ConfettiOverlay(burstID: confettiBurst)
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $formOpen) {
            NewQuestSheet(
                circles: circleStore.circles,
                onClose: { formOpen = false },
                onCreate: { title, emoji, steps, circleIDs in
                    let gradientKey = QuestContent.gradientKey(forQuestCount: questStore.quests.count)
                    questStore.addQuest(
                        title: title,
                        emoji: emoji,
                        gradientKey: gradientKey,
                        steps: steps,
                        circleIds: circleIDs.isEmpty ? nil : circleIDs
                    )
                    SparkHaptics.successNotification()
                    formOpen = false
                }
            )
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Quest Tracker")
                        .sparkTitle()
                    Text("Big goals, tiny doable steps. 🌱")
                        .font(SparkTypography.body())
                        .foregroundStyle(SparkColors.inkSoft)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                HeaderShortcutsView { route in
                    navigationPath.append(route)
                }
            }

            VStack(spacing: 4) {
                HStack(spacing: SparkSpacing.xs) {
                    SparkleBadge(size: 22, color: SparkColors.white)
                    Text("SPARKS EARNED")
                        .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.white)
                }

                Text("\(totalSparks)")
                    .font(SparkTypography.font(.displayBold, size: 52, relativeTo: .largeTitle))
                    .foregroundStyle(SparkColors.white)

                Text("Every step you finish lights one up ✨")
                    .font(SparkTypography.font(.body, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(SparkColors.white.opacity(0.95))
            }
            .padding(22)
            .frame(maxWidth: .infinity)
            .background(SparkTheme.gradient(.sunrise))
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
            .sparkSoftShadow()
            .padding(.top, 18)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Sparks earned")
            .accessibilityValue("\(totalSparks)")
        }
        .sparkFadeInDown(duration: 0.4)
    }

    private var newQuestButton: some View {
        SparkPrimaryButton(
            label: "New Quest",
            gradient: SparkTheme.gradient(.lavender),
            iconSystemName: "plus",
            action: { formOpen = true }
        )
        .padding(.top, SparkSpacing.xl)
        .sparkFadeInDown(delay: 0.12)
        .accessibilityLabel("New Quest")
    }

    @ViewBuilder
    private var emptyState: some View {
        if questStore.quests.isEmpty {
            SparkCard(backgroundColor: SparkColors.lavenderSoft) {
                VStack(spacing: 0) {
                    Text("🌈")
                        .font(.system(size: 40))
                    Text("No quests yet — that's okay!")
                        .font(SparkTypography.sectionTitle())
                        .foregroundStyle(SparkColors.ink)
                        .padding(.top, SparkSpacing.xs)
                    Text("Start with one tiny thing. You get to decide how small. 💗")
                        .font(SparkTypography.font(.body, size: 14, relativeTo: .subheadline))
                        .foregroundStyle(SparkColors.inkSoft)
                        .multilineTextAlignment(.center)
                        .lineSpacing(7)
                        .padding(.top, 6)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.top, 22)
            .sparkFadeInDown(delay: 0.2)
        }
    }

    @ViewBuilder
    private var questList: some View {
        if !questStore.quests.isEmpty {
            QuestReorderList(
                circles: circleStore.circles,
                onToggle: handleToggle,
                onDelete: handleDelete,
                onSetReminder: { questID, remindAt, notificationID in
                    questStore.setQuestReminder(
                        questID: questID,
                        remindAt: remindAt,
                        notificationID: notificationID
                    )
                },
                onClearReminder: { questID in
                    questStore.clearQuestReminder(questID: questID)
                },
                onToggleCircle: { questID, circleID in
                    questStore.toggleQuestCircle(questID: questID, circleID: circleID)
                }
            )
        }
    }

    private func handleToggle(quest: Quest, stepID: String) {
        let wasDone = quest.steps.first(where: { $0.id == stepID })?.done ?? false
        questStore.toggleStep(questID: quest.id, stepID: stepID)

        if !wasDone {
            let remaining = quest.steps.filter { !$0.done && $0.id != stepID }.count
            if remaining == 0 {
                SparkHaptics.successNotification()
                confettiBurst += 1
            } else {
                SparkHaptics.lightImpact()
            }
        } else {
            SparkHaptics.lightImpact()
        }
    }

    private func handleDelete(id: String) {
        let notificationID = questStore.deleteQuest(id: id)
        if let notificationID {
            Task {
                await SparkNotificationService.cancelReminder(id: notificationID)
            }
        }
    }
}

private struct ConfettiOverlay: View {
    let burstID: Int

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var pieces: [ConfettiPieceState] = []

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(pieces) { piece in
                    ConfettiPieceAnimatedView(piece: piece, containerSize: proxy.size)
                }
            }
        }
        .allowsHitTesting(false)
        .onChange(of: burstID) { _, _ in
            guard !reduceMotion else { return }
            pieces = (0..<80).map { ConfettiPieceState(index: $0) }
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                pieces = []
            }
        }
    }
}

private struct ConfettiPieceState: Identifiable {
    let id = UUID()
    let index: Int
    let startXRatio: CGFloat
    let startY: CGFloat
    let delay: Double
    let duration: Double
    let swayAmplitude: CGFloat
    let swayFrequency: Double
    let swayPhase: Double
    let spin: Double
    let flipPhase: Double
    let width: CGFloat
    let height: CGFloat
    let color: Color
    let isRound: Bool

    init(index: Int) {
        self.index = index
        let colors: [Color] = [
            SparkColors.lavender,
            SparkColors.pink,
            SparkColors.mint,
            SparkColors.yellow,
            SparkColors.sky,
            SparkColors.peach,
        ]
        startXRatio = Self.rand(index, salt: 1)
        startY = -40 - Self.rand(index, salt: 2) * 80
        delay = Double(Self.rand(index, salt: 3)) * 0.5
        duration = 2.6 * (0.75 + Self.rand(index, salt: 4) * 0.5)
        swayAmplitude = 18 + Self.rand(index, salt: 5) * 46
        swayFrequency = 2 + Double(Self.rand(index, salt: 6)) * 3
        swayPhase = Double(Self.rand(index, salt: 7)) * .pi * 2
        spin = (Self.rand(index, salt: 8) > 0.5 ? 1 : -1) * (360 + Double(Self.rand(index, salt: 9)) * 720)
        flipPhase = Double(Self.rand(index, salt: 10)) * .pi * 2
        width = 7 + floor(Self.rand(index, salt: 11) * 6)
        height = 9 + floor(Self.rand(index, salt: 12) * 8)
        color = colors[index % colors.count]
        isRound = index % 4 == 0
    }

    private static func rand(_ index: Int, salt: Int) -> CGFloat {
        let value = sin(Double(index) * 127.1 + Double(salt) * 311.7) * 43758.5453
        return CGFloat(value - floor(value))
    }
}

private struct ConfettiPieceAnimatedView: View {
    let piece: ConfettiPieceState
    let containerSize: CGSize

    @State private var progress: CGFloat = 0

    var body: some View {
        RoundedRectangle(
            cornerRadius: piece.isRound ? max(piece.width, piece.height) / 2 : 2,
            style: .continuous
        )
        .fill(piece.color)
        .frame(width: piece.width, height: piece.height)
        .scaleEffect(x: 0.35 + abs(cos(progress * 6 + piece.flipPhase)) * 0.65, y: 1)
        .rotationEffect(.degrees(piece.spin * progress))
        .opacity(opacity)
        .position(x: xPosition, y: yPosition)
        .onAppear {
            withAnimation(.easeIn(duration: piece.duration).delay(piece.delay)) {
                progress = 1
            }
        }
    }

    private var xPosition: CGFloat {
        piece.startXRatio * containerSize.width
            + sin(progress * piece.swayFrequency * .pi * 2 + piece.swayPhase) * piece.swayAmplitude
    }

    private var yPosition: CGFloat {
        piece.startY + (containerSize.height + 120) * progress
    }

    private var opacity: Double {
        let fadeIn = progress < 0.06 ? Double(progress / 0.06) : 1
        let fadeOut = progress > 0.85 ? Double(1 - (progress - 0.85) / 0.15) : 1
        return max(0, fadeIn * fadeOut)
    }
}

#Preview {
    NavigationStack {
        QuestsView()
    }
    .environment(QuestStore())
    .environment(CircleStore())
    .preferredColorScheme(.light)
}
