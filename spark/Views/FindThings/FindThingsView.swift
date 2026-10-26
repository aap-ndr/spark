//
//  FindThingsView.swift
//  Spark
//
//  Purpose:
//  Find My Things search and storage screen.
//
//  Responsibilities:
//  • Searches saved items, filters by category, and opens composers.
//

import SwiftUI

struct FindThingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(ThingsStore.self) private var thingsStore
    @Environment(AppNavigationCoordinator.self) private var navigation

    @State private var search = ""
    @State private var filter: ThingFilter = .all
    @State private var composerOpen = false
    @State private var editingItem: StoredItem?

    private var visibleItems: [StoredItem] {
        ThingsContent.visibleItems(from: thingsStore.items, search: search, filter: filter)
    }

    private var categoryCounts: [ThingCategory: Int] {
        ThingsContent.categoryCounts(for: thingsStore.items)
    }

    var body: some View {
        ZStack {
            SparkColors.cream.ignoresSafeArea()

            LinearGradient(
                colors: [SparkColors.mintSoft, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    headerSection
                    addButtonSection

                    if !thingsStore.items.isEmpty {
                        searchSection
                        categoryFilterSection
                    }

                    if thingsStore.items.isEmpty {
                        emptyStateSection
                    }

                    if !thingsStore.items.isEmpty && visibleItems.isEmpty {
                        filteredEmptySection
                    }

                    if !visibleItems.isEmpty {
                        itemsSection
                    }
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.bottom, 60)
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .safeAreaPadding(.top, SparkSpacing.sm)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $composerOpen) {
            ThingComposerSheet(
                editing: editingItem,
                onClose: { composerOpen = false },
                onSave: saveItem
            )
            .id(editingItem?.id ?? "new")
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button {
                    SparkHaptics.lightImpact()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(SparkColors.inkSoft)
                        Text("Home")
                            .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                            .foregroundStyle(SparkColors.inkSoft)
                    }
                    .frame(minHeight: SparkSpacing.minimumTouchTarget, alignment: .leading)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back to Home")

                Spacer()

                HeaderShortcutsView(color: SparkColors.mint) { route in
                    navigation.homePath.append(route)
                }
            }

            Text("Find My Things")
                .sparkTitle()
                .padding(.top, 10)

            Text("Put something down? Save where it is so you can find it later. 🔍")
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.inkSoft)
                .lineSpacing(6)
                .padding(.top, 2)
        }
        .sparkFadeInDown(duration: 0.4)
    }

    // MARK: - Add

    private var addButtonSection: some View {
        SparkPrimaryButton(
            label: "Save where something is",
            gradient: SparkTheme.gradient(.garden),
            iconSystemName: "plus",
            action: openAdd
        )
        .padding(.top, SparkSpacing.xl)
        .sparkFadeInDown(delay: 0.08)
    }

    // MARK: - Search

    private var searchSection: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .regular))
                .foregroundStyle(SparkColors.inkSoft)

            TextField("Where are my… (e.g. glasses)", text: $search)
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.ink)

            if !search.isEmpty {
                Button {
                    search = ""
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SparkColors.inkSoft)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, SparkSpacing.sm)
        .background(SparkColors.card)
        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
        .sparkSoftShadow()
        .padding(.top, SparkSpacing.lg)
        .sparkFadeInDown(delay: 0.12)
    }

    // MARK: - Category filters

    private var categoryFilterSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("CATEGORIES")
                .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, SparkSpacing.xl)

            ThingsFlowLayout(spacing: 10, rowSpacing: 10) {
                filterChip(
                    emoji: "🔍",
                    label: "All",
                    count: thingsStore.items.count,
                    active: filter == .all,
                    action: { pickFilter(.all) }
                )

                ForEach(ThingsContent.categories) { category in
                    let count = categoryCounts[category.id] ?? 0
                    filterChip(
                        emoji: category.emoji,
                        label: category.label,
                        count: count,
                        active: filter == .category(category.id),
                        showCount: count > 0,
                        action: { pickFilter(.category(category.id)) }
                    )
                }
            }
            .padding(.top, SparkSpacing.sm)
        }
        .sparkFadeInDown(delay: 0.15)
    }

    private func filterChip(
        emoji: String,
        label: String,
        count: Int,
        active: Bool,
        showCount: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(emoji)
                    .font(.system(size: 15))
                Text(label)
                    .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
                if showCount {
                    Text("\(count)")
                        .font(SparkTypography.font(.bodyBold, size: 12, relativeTo: .caption2))
                        .foregroundStyle(active ? SparkColors.white : SparkColors.mint)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(active ? SparkColors.mint : SparkColors.card)
            .clipShape(Capsule())
            .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(label), \(count) items")
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    // MARK: - Empty states

    private var emptyStateSection: some View {
        SparkCard(backgroundColor: SparkColors.mintSoft) {
            VStack(spacing: 0) {
                Image(systemName: "shippingbox.and.arrow.backward.fill")
                    .font(.system(size: 36, weight: .regular))
                    .foregroundStyle(SparkColors.mint)

                Text("Never lose track again ✨")
                    .font(SparkTypography.font(.displayBold, size: 17, relativeTo: .body))
                    .foregroundStyle(SparkColors.ink)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)

                Text("Tap the button above and tell me where you put your phone, keys, glasses — anything. I'll remember it for you. 💗")
                    .font(SparkTypography.body())
                    .foregroundStyle(SparkColors.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(7)
                    .padding(.top, 6)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, SparkSpacing.xxl)
        .sparkFadeInDown(delay: 0.16)
    }

    private var filteredEmptySection: some View {
        SparkCard(backgroundColor: SparkColors.lavenderSoft) {
            VStack(spacing: 0) {
                Text("🔍")
                    .font(.system(size: 30))
                    .accessibilityHidden(true)

                Text("Nothing matches \"\(search.trimmingCharacters(in: .whitespacesAndNewlines))\". Try another word, or save it as a new thing. 💗")
                    .font(SparkTypography.body())
                    .foregroundStyle(SparkColors.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(7)
                    .padding(.top, SparkSpacing.xs)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, SparkSpacing.xxl)
    }

    // MARK: - Items list

    private var itemsSection: some View {
        VStack(spacing: 10) {
            ForEach(visibleItems) { item in
                itemRow(item)
            }
        }
        .padding(.top, SparkSpacing.lg)
    }

    private func itemRow(_ item: StoredItem) -> some View {
        SparkCard {
            HStack(spacing: SparkSpacing.sm) {
                Button {
                    openEdit(item)
                } label: {
                    HStack(spacing: SparkSpacing.sm) {
                        Text(item.emoji ?? "📦")
                            .font(.system(size: 22))
                            .frame(width: 46, height: 46)
                            .background(SparkColors.mintSoft)
                            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))

                        VStack(alignment: .leading, spacing: 3) {
                            Text(item.name)
                                .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                                .foregroundStyle(SparkColors.ink)
                                .lineLimit(1)

                            HStack(spacing: 5) {
                                Image(systemName: "mappin")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(SparkColors.mint)
                                Text(item.location)
                                    .font(SparkTypography.body())
                                    .foregroundStyle(SparkColors.ink)
                                    .lineLimit(1)
                            }

                            if let note = item.note, !note.isEmpty {
                                Text(note)
                                    .font(SparkTypography.caption())
                                    .foregroundStyle(SparkColors.inkSoft)
                                    .lineLimit(1)
                            }

                            Text("updated \(ThingsContent.timeAgo(item.updatedAt))")
                                .font(SparkTypography.font(.body, size: 11, relativeTo: .caption2))
                                .foregroundStyle(SparkColors.inkSoft)
                                .padding(.top, 1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(item.name), \(item.location)")
                .accessibilityHint("Double tap to edit")

                Button {
                    deleteItem(item)
                } label: {
                    Image(systemName: "trash")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundStyle(SparkColors.inkSoft)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Delete \(item.name)")
            }
        }
    }

    // MARK: - Actions

    private func pickFilter(_ newFilter: ThingFilter) {
        SparkHaptics.lightImpact()
        filter = newFilter
    }

    private func openAdd() {
        SparkHaptics.lightImpact()
        editingItem = nil
        composerOpen = true
    }

    private func openEdit(_ item: StoredItem) {
        SparkHaptics.lightImpact()
        editingItem = item
        composerOpen = true
    }

    private func deleteItem(_ item: StoredItem) {
        SparkHaptics.mediumImpact()
        thingsStore.removeItem(id: item.id)
    }

    private func saveItem(_ input: ThingComposerInput) {
        if let editingItem {
            thingsStore.updateItem(id: editingItem.id, input: input)
        } else {
            thingsStore.addItem(input)
        }
        SparkHaptics.successNotification()
        composerOpen = false
    }
}

private struct ThingsFlowLayout: Layout {
    var spacing: CGFloat
    var rowSpacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        arrange(proposal: proposal, subviews: subviews).size
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
    NavigationStack {
        FindThingsView()
            .environment(ThingsStore())
            .environment(AppNavigationCoordinator())
    }
}
