//
//  QuestReorderList.swift
//  Spark
//
//  Purpose:
//  Drag-to-reorder quest list implementation.
//
//  Responsibilities:
//  • Handles live reordering and persistence of quest order.
//

import SwiftUI

private struct RowHeightPreferenceKey: PreferenceKey {
    static var defaultValue: [String: CGFloat] = [:]

    static func reduce(value: inout [String: CGFloat], nextValue: () -> [String: CGFloat]) {
        value.merge(nextValue(), uniquingKeysWith: { _, new in new })
    }
}

struct QuestReorderList: View {
    @Environment(QuestStore.self) private var questStore

    let circles: [SparkCircle]
    let onToggle: (Quest, String) -> Void
    let onDelete: (String) -> Void
    let onSetReminder: (String, Int64, String) -> Void
    let onClearReminder: (String) -> Void
    let onToggleCircle: (String, String) -> Void

    @State private var liveOrder: [String] = []
    @State private var rowHeights: [String: CGFloat] = [:]
    @State private var draggingID: String?
    @State private var dragOffset: CGFloat = 0

    private var questsByID: [String: Quest] {
        Dictionary(uniqueKeysWithValues: questStore.quests.map { ($0.id, $0) })
    }

    var body: some View {
        VStack(spacing: QuestContent.rowGap) {
            ForEach(Array(questStore.quests.enumerated()), id: \.element.id) { index, quest in
                questRow(quest: quest, index: index)
            }
        }
        .padding(.top, QuestContent.rowGap)
        .onAppear(perform: syncOrder)
        .onChange(of: questStore.quests.map(\.id)) { _, _ in
            syncOrderIfIdle()
        }
        .onPreferenceChange(RowHeightPreferenceKey.self) { rowHeights = $0 }
    }

    private func syncOrder() {
        liveOrder = questStore.quests.map(\.id)
    }

    private func syncOrderIfIdle() {
        guard draggingID == nil else { return }
        liveOrder = questStore.quests.map(\.id)
    }

    @ViewBuilder
    private func questRow(quest: Quest, index: Int) -> some View {
        let isDragging = draggingID == quest.id
        let displacement = rowDisplacement(for: quest.id, renderedIndex: index)

        QuestCardView(
            quest: quest,
            circles: circles,
            dragHandle: {
                dragHandle(for: quest)
            },
            onToggleStep: { stepID in
                onToggle(quest, stepID)
            },
            onDelete: {
                SparkHaptics.lightImpact()
                onDelete(quest.id)
            },
            onSetReminder: onSetReminder,
            onClearReminder: onClearReminder,
            onToggleCircle: onToggleCircle
        )
        .background(
            GeometryReader { proxy in
                Color.clear.preference(
                    key: RowHeightPreferenceKey.self,
                    value: [quest.id: proxy.size.height + QuestContent.rowGap]
                )
            }
        )
        .offset(y: isDragging ? dragOffset : displacement)
        .scaleEffect(isDragging ? 1.03 : 1)
        .shadow(
            color: SparkColors.softShadowColor.opacity(isDragging ? 0.28 : 0),
            radius: isDragging ? 28 : 0,
            x: 0,
            y: isDragging ? 14 : 0
        )
        .zIndex(isDragging ? 100 : 1)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: displacement)
        .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isDragging)
        .sparkFadeInDown(delay: 0.2 + Double(index) * 0.08)
    }

    private func dragHandle(for quest: Quest) -> some View {
        Image(systemName: "line.3.horizontal")
            .font(.system(size: 22, weight: .semibold))
            .foregroundStyle(SparkColors.inkSoft)
            .frame(width: 30)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .gesture(dragGesture(for: quest))
            .accessibilityLabel("Reorder quest")
            .accessibilityHint("Press and hold, then drag to reorder")
    }

    private func dragGesture(for quest: Quest) -> some Gesture {
        LongPressGesture(minimumDuration: 0.12)
            .sequenced(before: DragGesture(minimumDistance: 0))
            .onChanged { value in
                switch value {
                case .second(true, let drag?):
                    if draggingID == nil {
                        draggingID = quest.id
                        dragOffset = 0
                        SparkHaptics.mediumImpact()
                    }
                    dragOffset = drag.translation.height
                    updateOrderWhileDragging(activeID: quest.id, translation: drag.translation.height)
                default:
                    break
                }
            }
            .onEnded { _ in
                finishDrag()
            }
    }

    private func updateOrderWhileDragging(activeID: String, translation: CGFloat) {
        guard let currentIndex = liveOrder.firstIndex(of: activeID) else { return }
        let rowHeight = rowHeights[activeID] ?? 120
        var newIndex = currentIndex
        var offset = translation

        while offset > 0, newIndex < liveOrder.count - 1 {
            let belowID = liveOrder[newIndex + 1]
            let belowHeight = rowHeights[belowID] ?? rowHeight
            if offset > belowHeight / 2 {
                offset -= belowHeight
                newIndex += 1
                SparkHaptics.lightImpact()
            } else {
                break
            }
        }

        while offset < 0, newIndex > 0 {
            let aboveID = liveOrder[newIndex - 1]
            let aboveHeight = rowHeights[aboveID] ?? rowHeight
            if -offset > aboveHeight / 2 {
                offset += aboveHeight
                newIndex -= 1
                SparkHaptics.lightImpact()
            } else {
                break
            }
        }

        guard newIndex != currentIndex else { return }
        var updated = liveOrder
        updated.remove(at: currentIndex)
        updated.insert(activeID, at: newIndex)
        liveOrder = updated
    }

    private func finishDrag() {
        questStore.setQuestOrder(orderedIDs: liveOrder)
        SparkHaptics.successNotification()
        draggingID = nil
        dragOffset = 0
    }

    private func rowDisplacement(for id: String, renderedIndex: Int) -> CGFloat {
        guard draggingID != nil, draggingID != id else { return 0 }
        guard let liveIndex = liveOrder.firstIndex(of: id) else { return 0 }
        if liveIndex > renderedIndex {
            var delta: CGFloat = 0
            for index in renderedIndex..<liveIndex {
                let rowID = liveOrder[index + 1]
                delta += rowHeights[rowID] ?? 0
            }
            return delta
        }
        if liveIndex < renderedIndex {
            var delta: CGFloat = 0
            for index in liveIndex..<renderedIndex {
                let rowID = liveOrder[index]
                delta -= rowHeights[rowID] ?? 0
            }
            return delta
        }
        return 0
    }
}
