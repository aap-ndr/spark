//
//  RemindersView.swift
//  Spark
//
//  Purpose:
//  Reminders feature screen.
//
//  Responsibilities:
//  • Displays upcoming reminders, categories, and composer entry points.
//

import SwiftUI

struct RemindersView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(RemindersStore.self) private var remindersStore
    @Environment(ReminderCategoriesStore.self) private var categoriesStore
    @Environment(DatesStore.self) private var datesStore
    @Environment(QuestStore.self) private var questStore
    @Environment(CycleStore.self) private var cycleStore
    @Environment(AppNavigationCoordinator.self) private var navigation

    @State private var composerOpen = false
    @State private var editingReminder: Reminder?
    @State private var notice: String?
    @State private var categoryPendingDelete: ReminderCategory?

    private var upcoming: [UpcomingItem] {
        Array(
            UpcomingAggregator.aggregateUpcoming(
                dates: datesStore.dates,
                quests: questStore.quests,
                cycleEntries: cycleStore.entries,
                reminders: remindersStore.reminders,
                averageCycleLength: cycleStore.averageCycleLength,
                limit: 6
            ).prefix(6)
        )
    }

    var body: some View {
        ZStack(alignment: .top) {
            SparkColors.cream.ignoresSafeArea()

            LinearGradient(
                colors: [SparkColors.lavenderSoft, SparkColors.cream],
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
                    noticeSection
                    upcomingSection
                    emptyStateSection
                    remindersListSection
                }
                .padding(.horizontal, SparkSpacing.screenHorizontal)
                .padding(.bottom, 60)
            }
            .scrollContentBackground(.hidden)
            .scrollIndicators(.hidden)
            .safeAreaPadding(.top, SparkSpacing.sm)

            if let categoryPendingDelete {
                categoryDeleteOverlay(categoryPendingDelete)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $composerOpen) {
            ReminderComposerSheet(
                editing: editingReminder,
                categories: categoriesStore.categories,
                onClose: { composerOpen = false },
                onSave: saveReminder,
                onCreateCategory: { label, emoji in
                    categoriesStore.addCategory(label: label, emoji: emoji)
                },
                onRequestDeleteCategory: { category in
                    categoryPendingDelete = category
                }
            )
            .id(editingReminder?.id ?? "new")
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .task {
            await ReminderScheduler.refreshRecurringSchedules(in: remindersStore)
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

                HeaderShortcutsView(color: SparkColors.lavender, hideReminders: true) { route in
                    navigation.homePath.append(route)
                }
            }

            Text("Reminders")
                .sparkTitle()
                .padding(.top, 10)

            Text("Little nudges for the things that matter — medicine, water, calling your people. 🔔")
                .font(SparkTypography.body())
                .foregroundStyle(SparkColors.inkSoft)
                .lineSpacing(6)
                .padding(.top, 2)
        }
        .sparkFadeInDown(duration: 0.4)
    }

    private var addButtonSection: some View {
        SparkPrimaryButton(
            label: "New reminder",
            gradient: SparkTheme.gradient(.dream),
            iconSystemName: "plus",
            action: openAdd
        )
        .padding(.top, SparkSpacing.xl)
        .sparkFadeInDown(delay: 0.08)
    }

    @ViewBuilder
    private var noticeSection: some View {
        if let notice {
            Text(notice)
                .font(SparkTypography.supportive())
                .foregroundStyle(SparkColors.ink)
                .lineSpacing(7)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(SparkColors.yellowSoft)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .padding(.top, SparkSpacing.md)
        }
    }

    // MARK: - Coming up

    @ViewBuilder
    private var upcomingSection: some View {
        if !upcoming.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(SparkColors.lavender)
                    Text("Coming up")
                        .font(SparkTypography.font(.displayBold, size: 18, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                }

                Text("Pulled from your reminders, events, cycle & quests — tap to open.")
                    .font(SparkTypography.font(.body, size: 12.5, relativeTo: .footnote))
                    .foregroundStyle(SparkColors.inkSoft)
                    .lineSpacing(5)
                    .padding(.top, 3)

                VStack(spacing: 8) {
                    ForEach(upcoming) { item in
                        upcomingRow(item)
                    }
                }
                .padding(.top, SparkSpacing.sm)
            }
            .padding(.top, SparkSpacing.section)
            .sparkFadeInDown(delay: 0.12)
        }
    }

    private func upcomingRow(_ item: UpcomingItem) -> some View {
        Button {
            SparkHaptics.lightImpact()
            navigation.homePath.append(item.route)
        } label: {
            HStack(spacing: SparkSpacing.sm) {
                Text(item.emoji)
                    .font(.system(size: 20))
                    .frame(width: 40, height: 40)
                    .background(SparkColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(item.title)
                        .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                        .lineLimit(1)
                    Text(UpcomingAggregator.whenLabel(item.when))
                        .font(SparkTypography.font(.body, size: 12.5, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.inkSoft)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: "chevron.right")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SparkColors.lavender)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, SparkSpacing.sm)
            .background(SparkColors.lavenderSoft)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.lg, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(item.title), \(UpcomingAggregator.whenLabel(item.when))")
    }

    // MARK: - Empty state

    @ViewBuilder
    private var emptyStateSection: some View {
        if remindersStore.reminders.isEmpty {
            SparkCard(backgroundColor: SparkColors.lavenderSoft) {
                VStack(spacing: 0) {
                    Image(systemName: "bell.and.waves.left.and.right.fill")
                        .font(.system(size: 36, weight: .regular))
                        .foregroundStyle(SparkColors.lavender)

                    Text("Let me remember for you ✨")
                        .font(SparkTypography.font(.displayBold, size: 17, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)

                    Text("Set a reminder to take your medicine, drink water, or call someone you love — every day or just on certain days. 💗")
                        .font(SparkTypography.body())
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
    }

    // MARK: - Reminders list

    @ViewBuilder
    private var remindersListSection: some View {
        if !remindersStore.reminders.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("Your reminders")
                    .font(SparkTypography.font(.displayBold, size: 18, relativeTo: .body))
                    .foregroundStyle(SparkColors.ink)
                    .padding(.top, SparkSpacing.xxl)

                VStack(spacing: 10) {
                    ForEach(remindersStore.reminders) { reminder in
                        reminderRow(reminder)
                    }
                }
                .padding(.top, 14)
            }
        }
    }

    private func reminderRow(_ reminder: Reminder) -> some View {
        SparkCard {
            VStack(spacing: 0) {
                HStack(spacing: SparkSpacing.sm) {
                    Text(reminder.emoji ?? "🔔")
                        .font(.system(size: 22))
                        .frame(width: 46, height: 46)
                        .background(SparkColors.lavenderSoft)
                        .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(reminder.title)
                            .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                            .foregroundStyle(reminder.enabled ? SparkColors.ink : SparkColors.inkSoft)
                            .lineLimit(1)

                        HStack(spacing: 5) {
                            Image(systemName: "clock")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(SparkColors.lavender)
                            Text(RemindersContent.scheduleLabel(for: reminder))
                                .font(SparkTypography.body())
                                .foregroundStyle(SparkColors.inkSoft)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Toggle("", isOn: Binding(
                        get: { reminder.enabled },
                        set: { newValue in
                            toggleEnabled(reminder, enabled: newValue)
                        }
                    ))
                    .labelsHidden()
                    .tint(SparkColors.lavender)
                    .accessibilityLabel(reminder.enabled ? "Reminder on" : "Reminder off")
                }

                HStack(spacing: 10) {
                    Button {
                        openEdit(reminder)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "pencil")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(SparkColors.lavender)
                            Text("Edit")
                                .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                                .foregroundStyle(SparkColors.lavender)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, SparkSpacing.sm)
                        .background(SparkColors.lavenderSoft)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Edit \(reminder.title)")

                    Button {
                        deleteReminder(reminder)
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "trash")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(SparkColors.inkSoft)
                            Text("Delete")
                                .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                                .foregroundStyle(SparkColors.inkSoft)
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, SparkSpacing.sm)
                        .background(SparkColors.card)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Delete \(reminder.title)")
                }
                .padding(.top, SparkSpacing.sm)
            }
        }
        .accessibilityElement(children: .contain)
    }

    // MARK: - Category delete overlay

    private func categoryDeleteOverlay(_ category: ReminderCategory) -> some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    categoryPendingDelete = nil
                }

            VStack(spacing: 0) {
                Text(category.emoji)
                    .font(.system(size: 34))

                Text("Remove “\(category.label)”?")
                    .font(SparkTypography.font(.displayBold, size: 19, relativeTo: .title3))
                    .foregroundStyle(SparkColors.ink)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)

                Text("Reminders in this category will move to “Other”. Nothing gets deleted. 💗")
                    .font(SparkTypography.body())
                    .foregroundStyle(SparkColors.inkSoft)
                    .multilineTextAlignment(.center)
                    .lineSpacing(7)
                    .padding(.top, SparkSpacing.xs)

                HStack(spacing: 10) {
                    Button {
                        categoryPendingDelete = nil
                    } label: {
                        Text("Keep it")
                            .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                            .foregroundStyle(SparkColors.inkSoft)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(SparkColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                            .sparkSoftShadow()
                    }
                    .buttonStyle(.plain)

                    Button {
                        removeCategory(category)
                    } label: {
                        Text("Remove")
                            .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                            .foregroundStyle(SparkColors.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 13)
                            .background(SparkColors.pink)
                            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, SparkSpacing.xl)
            }
            .padding(SparkSpacing.section)
            .background(SparkColors.cream)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.xl, style: .continuous))
            .sparkSoftShadow()
            .padding(.horizontal, 32)
        }
    }

    // MARK: - Actions

    private func flashNotice(_ message: String) {
        notice = message
        Task {
            try? await Task.sleep(for: .seconds(4))
            await MainActor.run {
                if notice == message {
                    notice = nil
                }
            }
        }
    }

    private func openAdd() {
        SparkHaptics.lightImpact()
        editingReminder = nil
        composerOpen = true
    }

    private func openEdit(_ reminder: Reminder) {
        SparkHaptics.lightImpact()
        editingReminder = reminder
        composerOpen = true
    }

    private func deleteReminder(_ reminder: Reminder) {
        SparkHaptics.mediumImpact()
        let ids = remindersStore.removeReminder(id: reminder.id)
        Task {
            await SparkNotificationService.cancelReminders(ids: ids)
        }
    }

    private func toggleEnabled(_ reminder: Reminder, enabled: Bool) {
        SparkHaptics.lightImpact()
        remindersStore.setEnabled(id: reminder.id, enabled: enabled)
        guard let updated = remindersStore.reminder(id: reminder.id) else { return }
        Task {
            let permissionDenied = await ReminderScheduler.schedule(for: updated) { id, ids in
                remindersStore.setNotificationIds(id: id, notificationIds: ids)
            }
            if enabled && permissionDenied {
                await MainActor.run {
                    flashNotice("Saved! Notifications are off, so I can't nudge you. Turn them on in Settings. 💗")
                }
            }
        }
    }

    private func saveReminder(_ input: ReminderInput) {
        SparkHaptics.successNotification()
        let target: Reminder
        if let editingReminder {
            remindersStore.updateReminder(id: editingReminder.id, input: input)
            target = remindersStore.reminder(id: editingReminder.id) ?? editingReminder
        } else {
            target = remindersStore.addReminder(input)
        }
        composerOpen = false
        Task {
            let permissionDenied = await ReminderScheduler.schedule(for: target) { id, ids in
                remindersStore.setNotificationIds(id: id, notificationIds: ids)
            }
            if target.enabled && permissionDenied {
                await MainActor.run {
                    flashNotice("Saved! Notifications are off, so I can't nudge you. Turn them on in Settings. 💗")
                }
            }
        }
    }

    private func removeCategory(_ category: ReminderCategory) {
        SparkHaptics.mediumImpact()
        categoriesStore.removeCategory(id: category.id)
        categoryPendingDelete = nil
    }
}

#Preview {
    NavigationStack {
        RemindersView()
            .environment(RemindersStore())
            .environment(ReminderCategoriesStore())
            .environment(DatesStore())
            .environment(QuestStore())
            .environment(CycleStore())
            .environment(AppNavigationCoordinator())
    }
}
