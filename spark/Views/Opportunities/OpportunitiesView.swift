//
//  OpportunitiesView.swift
//  Spark
//
//  Purpose:
//  Discover Opportunities browsing screen.
//
//  Responsibilities:
//  • Loads opportunities, filters results, and opens detail sheets.
//

import SwiftUI

struct OpportunitiesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppNavigationCoordinator.self) private var navigation
    @Environment(SavedOpportunitiesStore.self) private var savedStore

    @State private var opportunities: [Opportunity] = []
    @State private var isLoading = true
    @State private var filter: OpportunityFilter = .all
    @State private var detailOpportunity: Opportunity?
    @State private var safariDestination: SafariDestination?

    private let repository: any OpportunityRepositoryProtocol = LocalOpportunityRepository()

    private var filteredOpportunities: [Opportunity] {
        switch filter {
        case .all:
            return opportunities
        case .saved:
            return opportunities.filter { savedStore.isSaved($0.id) }
        case .category(let category):
            return opportunities.filter { $0.category == category }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            SparkColors.cream.ignoresSafeArea()

            LinearGradient(
                colors: [SparkColors.skySoft, SparkColors.cream],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 200)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea(edges: .top)
            .accessibilityHidden(true)

            VStack(spacing: 0) {
                headerSection
                filterSection

                if isLoading {
                    loadingSection
                } else {
                    listSection
                }
            }
            .safeAreaPadding(.top, SparkSpacing.md)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .task {
            isLoading = true
            opportunities = await repository.fetchOpportunities()
            isLoading = false
        }
        .sheet(item: $detailOpportunity) { opportunity in
            OpportunityDetailSheet(
                opportunity: opportunity,
                isSaved: savedStore.isSaved(opportunity.id),
                onClose: { detailOpportunity = nil },
                onApply: { openOpportunity(opportunity) },
                onToggleSaved: {
                    SparkHaptics.lightImpact()
                    savedStore.toggle(opportunity.id)
                }
            )
            .presentationDetents([.fraction(0.85)])
            .presentationDragIndicator(.visible)
            .presentationBackground(SparkColors.cream)
        }
        .sheet(item: $safariDestination) { destination in
            SafariView(url: destination.url)
                .ignoresSafeArea()
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
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

                HeaderShortcutsView(color: SparkColors.sky) { route in
                    navigation.homePath.append(route)
                }
            }

            Text("Discover")
                .sparkTitle()

            Text("Camps, clubs & chances to shine 🌟")
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.inkSoft)
                .padding(.top, 4)
        }
        .padding(.horizontal, SparkSpacing.screenHorizontal)
        .sparkFadeInDown(duration: 0.4)
    }

    // MARK: - Filters

    private var filterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(OpportunityFilter.filterOrder) { item in
                    filterChip(item)
                }
            }
            .padding(.horizontal, SparkSpacing.screenHorizontal)
            .padding(.vertical, 6)
        }
        .padding(.top, 16)
    }

    private func filterChip(_ item: OpportunityFilter) -> some View {
        let isSelected = filter == item

        return Button {
            SparkHaptics.lightImpact()
            filter = item
        } label: {
            Text(item.label)
                .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                .foregroundStyle(isSelected ? SparkColors.white : SparkColors.inkSoft)
                .lineLimit(1)
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(isSelected ? SparkColors.ink : SparkColors.white)
                .clipShape(Capsule())
                .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.label)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    // MARK: - Loading

    private var loadingSection: some View {
        VStack(spacing: 10) {
            ProgressView()
                .tint(SparkColors.lavender)
            Text("Finding opportunities…")
                .font(SparkTypography.font(.body, size: 14, relativeTo: .subheadline))
                .foregroundStyle(SparkColors.inkSoft)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 40)
    }

    // MARK: - List

    private var listSection: some View {
        ScrollView {
            if filteredOpportunities.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(Array(filteredOpportunities.enumerated()), id: \.element.id) { index, opportunity in
                        OpportunityCardView(
                            opportunity: opportunity,
                            isSaved: savedStore.isSaved(opportunity.id),
                            onOpenDetail: {
                                SparkHaptics.lightImpact()
                                detailOpportunity = opportunity
                            },
                            onToggleSaved: {
                                SparkHaptics.lightImpact()
                                savedStore.toggle(opportunity.id)
                            },
                            onCheckItOut: {
                                openOpportunity(opportunity)
                            }
                        )
                        .padding(.bottom, 14)
                        .sparkFadeInDown(delay: Double(index) * 0.06)
                    }
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.top, 18)
                .padding(.bottom, 40)
            }
        }
        .scrollIndicators(.hidden)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "bookmark")
                .font(.system(size: 40, weight: .regular))
                .foregroundStyle(SparkColors.inkSoft)
                .accessibilityHidden(true)

            Text(emptyStateMessage)
                .font(SparkTypography.font(.body, size: 15, relativeTo: .body))
                .foregroundStyle(SparkColors.inkSoft)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
        .padding(.horizontal, SparkSpacing.screenHorizontal)
    }

    private var emptyStateMessage: String {
        if filter == .saved {
            return "No saved opportunities yet.\nTap the bookmark to save one!"
        }
        return "Nothing here yet — check back soon 💫"
    }

    // MARK: - Links

    private func openOpportunity(_ opportunity: Opportunity) {
        SparkHaptics.lightImpact()
        guard let destination = SafariDestination(urlString: opportunity.externalURLString) else {
            return
        }
        safariDestination = destination
    }
}

#Preview {
    NavigationStack {
        OpportunitiesView()
    }
    .environment(AppNavigationCoordinator())
    .environment(SavedOpportunitiesStore())
}
