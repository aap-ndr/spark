//
//  DatesView.swift
//  Spark
//
//  Purpose:
//  Important dates and events screen.
//
//  Responsibilities:
//  • Lists upcoming events and opens the date composer.
//

import SwiftUI

struct DatesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DatesStore.self) private var datesStore
    @Environment(NotifSettingsStore.self) private var notifSettingsStore
    @Environment(AppNavigationCoordinator.self) private var navigation

    @State private var composerOpen = false
    @State private var editingItem: ImportantDate?
    @State private var composerCategory: DateCategory = .birthday

    private var sortedDates: [ImportantDate] {
        datesStore.sortedByNextOccurrence
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

                    if datesStore.dates.isEmpty {
                        emptyStateSection
                    }

                    if !sortedDates.isEmpty {
                        upcomingSection
                    }
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.bottom, 60)
            }
            .safeAreaPadding(.top, SparkSpacing.sm)
            .scrollIndicators(.hidden)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $composerOpen) {
            DateComposerSheet(
                editing: editingItem,
                initialCategory: composerCategory,
                onClose: { composerOpen = false },
                onSave: saveEvent
            )
            .id(editingItem?.id ?? "new-\(composerCategory.rawValue)")
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

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

                HStack(spacing: 10) {
                    HeaderShortcutsView(color: SparkColors.mint) { route in
                        navigation.homePath.append(route)
                    }

                    Button {
                        SparkHaptics.lightImpact()
                        navigation.homePath.append(AppRoute.notificationSettings)
                    } label: {
                        Image(systemName: "gearshape")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(SparkColors.mint)
                            .frame(width: 44, height: 44)
                            .background(SparkColors.card)
                            .clipShape(Capsule())
                            .sparkSoftShadow()
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Notification settings")
                }
            }

            Text("Events")
                .sparkTitle()
                .padding(.top, 10)

            Text("Birthdays, big school days and your own special moments — I'll gently remind you. 🌷")
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.inkSoft)
                .lineSpacing(6)
                .padding(.top, 2)
        }
        .sparkFadeInDown(duration: 0.4)
    }

    private var addButtonSection: some View {
        SparkPrimaryButton(
            label: "Add an event",
            gradient: SparkTheme.gradient(.garden),
            iconSystemName: "plus",
            action: openComposer
        )
        .padding(.top, SparkSpacing.xl)
        .sparkFadeInDown(delay: 0.09)
    }

    private var emptyStateSection: some View {
        SparkCard(backgroundColor: SparkColors.mintSoft) {
            VStack(spacing: 0) {
                Image(systemName: "calendar.badge.heart")
                    .font(.system(size: 34, weight: .regular))
                    .foregroundStyle(SparkColors.mint)

                Text("Let's fill your calendar ✨")
                    .font(SparkTypography.font(.displayBold, size: 17, relativeTo: .body))
                    .foregroundStyle(SparkColors.ink)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)

                Text("Save a birthday 🎂, an exam 📝, prom 👗 or any moment you don't want to miss. Tap “Add an event”, pick a category, and I'll nudge you before it arrives. 💗")
                    .font(SparkTypography.bodyLarge())
                    .foregroundStyle(SparkColors.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(7)
                    .padding(.top, 6)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.top, SparkSpacing.xxl)
        .sparkFadeInDown(delay: 0.18)
    }

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Upcoming")
                .sparkSectionTitle()
                .padding(.top, SparkSpacing.sectionTop)

            VStack(spacing: 10) {
                ForEach(sortedDates) { item in
                    DateRowView(
                        item: item,
                        onEdit: { openEdit(item) },
                        onDelete: { deleteItem(item) }
                    )
                }
            }
            .padding(.top, 14)
        }
        .sparkFadeInDown(delay: 0.18)
    }

    private func openComposer() {
        SparkHaptics.lightImpact()
        editingItem = nil
        composerCategory = .birthday
        composerOpen = true
    }

    private func openEdit(_ item: ImportantDate) {
        SparkHaptics.lightImpact()
        editingItem = item
        composerCategory = item.category
        composerOpen = true
    }

    private func deleteItem(_ item: ImportantDate) {
        SparkHaptics.mediumImpact()
        Task {
            if let notificationID = item.notificationId {
                await SparkNotificationService.cancelReminder(id: notificationID)
            }
            await MainActor.run {
                datesStore.removeDate(id: item.id)
            }
        }
    }

    private func saveEvent(_ input: DateComposerInput) async -> Bool {
        var permissionDenied = false
        let settings = notifSettingsStore.snapshot

        if let editingItem {
            if let oldID = editingItem.notificationId {
                await SparkNotificationService.cancelReminder(id: oldID)
            }

            var merged = editingItem
            merged.title = input.title
            merged.category = input.category
            merged.customCategory = input.customCategory
            merged.date = input.date
            merged.time = input.time
            merged.recurring = input.recurring
            merged.reminderEnabled = input.reminderEnabled
            merged.reminderDaysBefore = input.reminderDaysBefore
            merged.notes = input.notes
            merged.notificationId = nil

            await MainActor.run {
                datesStore.updateDate(merged)
                SparkHaptics.successNotification()
            }

            if input.reminderEnabled {
                if settings.enabled, settings.perCategory[input.category] == true {
                    let itemSettings = DateReminderScheduler.settingsForItem(merged, base: settings)
                    if let notificationID = await DateReminderScheduler.scheduleDateReminder(item: merged, settings: itemSettings) {
                        await MainActor.run {
                            datesStore.updateDate(id: merged.id, notificationId: notificationID)
                        }
                    } else {
                        permissionDenied = true
                    }
                } else {
                    permissionDenied = true
                }
            }
        } else {
            let id = DatesStore.generateID()
            var item = ImportantDate(
                id: id,
                title: input.title,
                date: input.date,
                time: input.time,
                category: input.category,
                customCategory: input.customCategory,
                recurring: input.recurring,
                reminderEnabled: input.reminderEnabled,
                reminderDaysBefore: input.reminderDaysBefore,
                notificationId: nil,
                notes: input.notes,
                createdAt: Int64(Date().timeIntervalSince1970 * 1000)
            )

            await MainActor.run {
                datesStore.addDate(item)
                SparkHaptics.successNotification()
            }

            if input.reminderEnabled {
                if settings.enabled, settings.perCategory[input.category] == true {
                    let itemSettings = DateReminderScheduler.settingsForItem(item, base: settings)
                    if let notificationID = await DateReminderScheduler.scheduleDateReminder(item: item, settings: itemSettings) {
                        await MainActor.run {
                            datesStore.updateDate(id: id, notificationId: notificationID)
                        }
                    } else {
                        permissionDenied = true
                    }
                } else {
                    permissionDenied = true
                }
            }
        }

        return permissionDenied
    }
}

private struct DateRowView: View {
    let item: ImportantDate
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var meta: DateCategoryMeta {
        DatesContent.meta(for: item.category)
    }

    private var occurrence: Int64 {
        UpcomingAggregator.nextOccurrence(date: item.date, recurring: item.recurring)
    }

    var body: some View {
        SparkCard {
            HStack(spacing: SparkSpacing.sm) {
                Text(meta.emoji)
                    .font(.system(size: 22))
                    .frame(width: 46, height: 46)
                    .background(meta.fill)
                    .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))

                VStack(alignment: .leading, spacing: 3) {
                    Text(item.title)
                        .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                        .lineLimit(1)

                    HStack(spacing: 6) {
                        Text(DatesContent.displayLabel(for: item))
                            .font(SparkTypography.font(.bodyBold, size: 11, relativeTo: .caption2))
                            .foregroundStyle(SparkColors.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(meta.accent)
                            .clipShape(Capsule())

                        if item.recurring == .yearly {
                            HStack(spacing: 3) {
                                Image(systemName: "repeat")
                                    .font(.system(size: 11, weight: .semibold))
                                    .foregroundStyle(SparkColors.inkSoft)
                                Text("yearly")
                                    .font(SparkTypography.font(.bodyBold, size: 11, relativeTo: .caption2))
                                    .foregroundStyle(SparkColors.inkSoft)
                            }
                        }
                    }

                    Text(subtitleText)
                        .font(SparkTypography.caption())
                        .foregroundStyle(SparkColors.inkSoft)
                        .padding(.top, 1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(spacing: SparkSpacing.sm) {
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(SparkColors.inkSoft)
                            .frame(width: 44, height: 22)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Edit \(item.title)")

                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 18, weight: .regular))
                            .foregroundStyle(SparkColors.inkSoft)
                            .frame(width: 44, height: 22)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Delete \(item.title)")
                }
            }
        }
        .accessibilityElement(children: .contain)
    }

    private var subtitleText: String {
        var text = DatesContent.formatDate(occurrence)
        if let time = item.time {
            text += " · \(DatesContent.formatTime(hour: time.hour, minute: time.minute))"
        }
        text += " · \(DatesContent.countdownLabel(target: occurrence))"
        return text
    }
}

#Preview {
    NavigationStack {
        DatesView()
            .environment(DatesStore())
            .environment(NotifSettingsStore())
            .environment(AppNavigationCoordinator())
    }
}
