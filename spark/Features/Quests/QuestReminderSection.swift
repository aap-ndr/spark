//
//  QuestReminderSection.swift
//  Spark
//
//  Purpose:
//  Quest reminder configuration section.
//
//  Responsibilities:
//  • Edits reminder timing attached to a quest.
//

import SwiftUI

struct QuestReminderSection: View {
    let quest: Quest
    let onSetReminder: (String, Int64, String) -> Void
    let onClearReminder: (String) -> Void

    @State private var pickerPresentation: ReminderPickerPresentation?
    @State private var denied = false

    private var hasReminder: Bool {
        quest.remindAt != nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: SparkSpacing.xs) {
                Button(action: openPicker) {
                    HStack(spacing: SparkSpacing.xs) {
                        Image(systemName: hasReminder ? "bell.badge.fill" : "bell")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(hasReminder ? SparkColors.lavender : SparkColors.inkSoft)
                        Text(hasReminder && quest.remindAt != nil
                            ? QuestContent.formatReminder(milliseconds: quest.remindAt!)
                            : "Add reminder")
                            .font(SparkTypography.accentLink())
                            .foregroundStyle(hasReminder ? SparkColors.lavender : SparkColors.inkSoft)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(SparkColors.lavenderSoft)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .frame(minHeight: 44)
                .accessibilityLabel(hasReminder ? "Edit quest reminder" : "Add quest reminder")

                if hasReminder {
                    Button(action: clearReminder) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(SparkColors.inkSoft)
                            .frame(width: 30, height: 30)
                            .background(SparkColors.lavenderSoft)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear quest reminder")
                }
            }

            if denied {
                Text("Notifications are off. Turn them on in Settings to get quest reminders. 💗")
                    .font(SparkTypography.caption())
                    .foregroundStyle(SparkColors.inkSoft)
                    .lineSpacing(5)
                    .padding(.top, SparkSpacing.xs)
            }
        }
        .sheet(item: $pickerPresentation) { presentation in
            QuestReminderPickerSheet(
                initialDate: presentation.date,
                onCancel: { pickerPresentation = nil },
                onConfirm: { chosen in
                    pickerPresentation = nil
                    schedule(chosen)
                }
            )
        }
    }

    private struct ReminderPickerPresentation: Identifiable {
        let id = UUID()
        let date: Date
    }

    private func openPicker() {
        SparkHaptics.lightImpact()
        var initial = Date().addingTimeInterval(3600)
        initial = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: initial)) ?? initial
        pickerPresentation = ReminderPickerPresentation(date: initial)
    }

    private func schedule(_ date: Date) {
        denied = false
        guard date.timeIntervalSinceNow > 0 else { return }

        Task {
            let granted = await SparkNotificationService.requestPermission()
            await MainActor.run {
                if !granted {
                    denied = true
                    return
                }
            }

            if let existingID = quest.notificationId {
                await SparkNotificationService.cancelReminder(id: existingID)
            }

            let title = "\(quest.emoji) \(quest.title)"
            let notificationID = await SparkNotificationService.scheduleReminder(
                title: title,
                body: "Time for a tiny step on your quest ✨",
                date: date
            )

            await MainActor.run {
                if let notificationID {
                    onSetReminder(quest.id, Int64(date.timeIntervalSince1970 * 1000), notificationID)
                    SparkHaptics.successNotification()
                }
            }
        }
    }

    private func clearReminder() {
        SparkHaptics.lightImpact()
        Task {
            if let notificationID = quest.notificationId {
                await SparkNotificationService.cancelReminder(id: notificationID)
            }
            await MainActor.run {
                onClearReminder(quest.id)
                denied = false
            }
        }
    }
}

private struct QuestReminderPickerSheet: View {
    let initialDate: Date
    let onCancel: () -> Void
    let onConfirm: (Date) -> Void

    @State private var selectedDate: Date

    init(initialDate: Date, onCancel: @escaping () -> Void, onConfirm: @escaping (Date) -> Void) {
        self.initialDate = initialDate
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        _selectedDate = State(initialValue: initialDate)
    }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Remind me when?")
                    .font(SparkTypography.font(.displayBold, size: 20, relativeTo: .title3))
                    .foregroundStyle(SparkColors.ink)
                Spacer()
                Button(action: onCancel) {
                    Image(systemName: "xmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(SparkColors.inkSoft)
                        .frame(width: 44, height: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Close reminder picker")
            }
            .padding(.horizontal, SparkSpacing.section)
            .padding(.top, SparkSpacing.section)

            DatePicker(
                "Reminder date and time",
                selection: $selectedDate,
                in: Date()...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .padding(.horizontal, SparkSpacing.section)

            SparkPrimaryButton(
                label: "Set reminder",
                gradient: SparkTheme.gradient(.sunrise),
                iconSystemName: "bell.badge.fill",
                action: { onConfirm(selectedDate) }
            )
            .padding(.horizontal, SparkSpacing.section)
            .padding(.bottom, SparkSpacing.section)
        }
        .background(SparkColors.cream)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    QuestReminderSection(
        quest: Quest(
            id: "1",
            title: "Test",
            emoji: "✨",
            color: "lavender",
            steps: [],
            createdAt: 0,
            remindAt: nil,
            notificationId: nil,
            circleIds: nil
        ),
        onSetReminder: { _, _, _ in },
        onClearReminder: { _ in }
    )
    .padding()
    .background(SparkColors.cream)
}
