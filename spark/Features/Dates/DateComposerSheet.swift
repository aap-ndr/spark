//
//  DateComposerSheet.swift
//  Spark
//
//  Purpose:
//  Composer for important dates and events.
//
//  Responsibilities:
//  • Creates and edits dated events with optional reminders.
//

import SwiftUI

struct DateComposerSheet: View {
    let editing: ImportantDate?
    let initialCategory: DateCategory
    let onClose: () -> Void
    let onSave: (DateComposerInput) async -> Bool

    @State private var title = ""
    @State private var category: DateCategory = .birthday
    @State private var customCategory = ""
    @State private var date = Date()
    @State private var time: EventTime?
    @State private var recurring: DateRecurrence = .yearly
    @State private var reminderEnabled = true
    @State private var daysBefore = 1
    @State private var notes = ""
    @State private var showDatePicker = false
    @State private var showTimePicker = false
    @State private var notice: String?
    @State private var saving = false
    @State private var originalSnapshot = DateDraftSnapshot.empty
    @State private var showDiscardAlert = false

    private var hasUnsavedChanges: Bool {
        currentSnapshot() != originalSnapshot
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    categorySection
                    customCategorySection
                    titleSection
                    schoolTemplatesSection
                    whenSection
                    timeSection
                    repeatSection
                    reminderSection
                    reminderTimingSection
                    notesSection
                    noticeSection
                }
                .padding(.horizontal, SparkSpacing.section)
                .padding(.bottom, 44)
            }
            .scrollIndicators(.hidden)
            .background(SparkColors.cream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editing == nil ? "New event" : "Edit event")
                        .font(SparkTypography.font(.displayBold, size: 22, relativeTo: .title3))
                        .foregroundStyle(SparkColors.ink)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: requestClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(SparkColors.inkSoft)
                            .frame(width: 44, height: 44)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Close")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                    .disabled(!canSave)
                    .accessibilityLabel(editing == nil ? "Save event" : "Save changes")
                }
            }
        }
        .unsavedChangesDismissDisabled(hasUnsavedChanges)
        .discardChangesAlert(
            isPresented: $showDiscardAlert,
            message: UnsavedChangesGuard.formMessage("event"),
            onDiscard: onClose
        )
        .onAppear(perform: resetFields)
        .onChange(of: editing?.id) { _, _ in
            resetFields()
        }
        .onChange(of: initialCategory) { _, _ in
            if editing == nil {
                resetFields()
            }
        }
    }

    private var canSave: Bool {
        guard !saving else { return false }
        if !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return true
        }
        if let editing, !editing.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return true
        }
        return false
    }

    private var meta: DateCategoryMeta {
        DatesContent.meta(for: category)
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("CATEGORY")
            DatesFlowLayout(spacing: 10, rowSpacing: 10) {
                ForEach(DatesContent.categoryOrder, id: \.self) { item in
                    categoryChip(item)
                }
            }
            .padding(.top, 10)
        }
        .padding(.top, SparkSpacing.sm)
    }

    private func categoryChip(_ item: DateCategory) -> some View {
        let itemMeta = DatesContent.meta(for: item)
        let active = item == category

        return Button {
            SparkHaptics.lightImpact()
            category = item
            recurring = DatesContent.defaultRecurrence(for: item)
        } label: {
            HStack(spacing: 6) {
                Text(itemMeta.emoji)
                    .font(.system(size: 15))
                Text(itemMeta.label)
                    .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(active ? itemMeta.accent : SparkColors.card)
            .clipShape(Capsule())
            .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(itemMeta.label)
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    @ViewBuilder
    private var customCategorySection: some View {
        if category == .custom {
            VStack(alignment: .leading, spacing: 0) {
                sectionLabel("YOUR CATEGORY NAME")
                TextField("e.g. Anniversary, Pet day…", text: $customCategory)
                    .font(SparkTypography.bodyLarge())
                    .foregroundStyle(SparkColors.ink)
                    .padding(.horizontal, SparkSpacing.md)
                    .padding(.vertical, 14)
                    .background(SparkColors.card)
                    .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                    .sparkSoftShadow()
                    .padding(.top, 10)
            }
            .padding(.top, SparkSpacing.lg)
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("WHAT'S THE OCCASION?")
            TextField(DatesContent.titlePlaceholder(for: category), text: $title)
                .font(SparkTypography.bodyLarge())
                .foregroundStyle(SparkColors.ink)
                .padding(.horizontal, SparkSpacing.md)
                .padding(.vertical, 14)
                .background(SparkColors.card)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .sparkSoftShadow()
                .padding(.top, 10)
        }
        .padding(.top, SparkSpacing.lg)
    }

    @ViewBuilder
    private var schoolTemplatesSection: some View {
        if category == .school {
            VStack(alignment: .leading, spacing: 0) {
                sectionLabel("QUICK START")
                DatesFlowLayout(spacing: 8, rowSpacing: 8) {
                    ForEach(DatesContent.schoolTemplates, id: \.self) { template in
                        Button {
                            SparkHaptics.lightImpact()
                            title = template
                        } label: {
                            Text(template)
                                .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                                .foregroundStyle(SparkColors.sky)
                                .padding(.horizontal, SparkSpacing.sm)
                                .padding(.vertical, 8)
                                .background(SparkColors.skySoft)
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 10)
            }
            .padding(.top, SparkSpacing.md)
        }
    }

    private var whenSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("WHEN?")
            Button {
                SparkHaptics.lightImpact()
                showDatePicker.toggle()
            } label: {
                HStack(spacing: SparkSpacing.xs) {
                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(meta.accent)
                    Text(DatesContent.formatDate(DatesContent.toMidnight(date)))
                        .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, SparkSpacing.md)
                .padding(.vertical, 14)
                .background(meta.fill)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.top, 10)

            if showDatePicker {
                DatePicker(
                    "Event date",
                    selection: $date,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .labelsHidden()
                .padding(.top, SparkSpacing.xs)
            }
        }
        .padding(.top, SparkSpacing.lg)
    }

    private var timeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("WHAT TIME? (OPTIONAL)")
            HStack(spacing: 10) {
                Button {
                    SparkHaptics.lightImpact()
                    showTimePicker.toggle()
                } label: {
                    HStack(spacing: SparkSpacing.xs) {
                        Image(systemName: "clock")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(meta.accent)
                        Text(time.map { DatesContent.formatTime(hour: $0.hour, minute: $0.minute) } ?? "No specific time")
                            .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                            .foregroundStyle(SparkColors.ink)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, SparkSpacing.md)
                    .padding(.vertical, 14)
                    .background(meta.fill)
                    .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                }
                .buttonStyle(.plain)

                if time != nil {
                    Button {
                        SparkHaptics.lightImpact()
                        time = nil
                        showTimePicker = false
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(SparkColors.inkSoft)
                            .frame(width: 46, height: 46)
                            .background(SparkColors.card)
                            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                            .sparkSoftShadow()
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear time")
                }
            }
            .padding(.top, 10)

            if showTimePicker {
                DatePicker(
                    "Event time",
                    selection: Binding(
                        get: {
                            var components = DateComponents()
                            components.hour = time?.hour ?? 9
                            components.minute = time?.minute ?? 0
                            return Calendar.current.date(from: components) ?? Date()
                        },
                        set: { newValue in
                            let parts = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                            time = EventTime(hour: parts.hour ?? 0, minute: parts.minute ?? 0)
                        }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.top, SparkSpacing.xs)
            }
        }
        .padding(.top, SparkSpacing.lg)
    }

    private var repeatSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("REPEAT")
            HStack(spacing: 10) {
                recurrenceButton(.yearly, label: "Every year")
                recurrenceButton(.once, label: "Just once")
            }
            .padding(.top, 10)
        }
        .padding(.top, SparkSpacing.lg)
    }

    private func recurrenceButton(_ value: DateRecurrence, label: String) -> some View {
        let active = recurring == value

        return Button {
            SparkHaptics.lightImpact()
            recurring = value
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "repeat")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
                Text(label)
                    .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, SparkSpacing.sm)
            .background(active ? SparkColors.mint : SparkColors.card)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
            .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    private var reminderSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("REMINDER")
            HStack {
                HStack(spacing: SparkSpacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SparkColors.mint)
                    Text(reminderEnabled ? "I'll remind you" : "No reminder")
                        .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                }
                Spacer()
                Toggle("", isOn: $reminderEnabled)
                    .labelsHidden()
                    .tint(SparkColors.mint)
                    .onChange(of: reminderEnabled) { _, _ in
                        SparkHaptics.lightImpact()
                    }
            }
            .padding(.horizontal, SparkSpacing.md)
            .padding(.vertical, SparkSpacing.sm)
            .background(SparkColors.card)
            .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
            .sparkSoftShadow()
            .padding(.top, 10)
        }
        .padding(.top, SparkSpacing.lg)
    }

    @ViewBuilder
    private var reminderTimingSection: some View {
        if reminderEnabled {
            VStack(alignment: .leading, spacing: 0) {
                sectionLabel("REMIND ME")
                DatesFlowLayout(spacing: 8, rowSpacing: 8) {
                    ForEach(DatesContent.reminderChips) { chip in
                        reminderChip(chip)
                    }
                }
                .padding(.top, 10)
            }
            .padding(.top, SparkSpacing.lg)
        }
    }

    private func reminderChip(_ chip: ReminderChipOption) -> some View {
        let active = chip.value == daysBefore

        return Button {
            SparkHaptics.lightImpact()
            daysBefore = chip.value
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "clock")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
                Text(chip.label)
                    .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(active ? SparkColors.lavender : SparkColors.card)
            .clipShape(Capsule())
            .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("NOTES (OPTIONAL)")
            TextField("Any details…", text: $notes, axis: .vertical)
                .font(SparkTypography.bodyLarge())
                .foregroundStyle(SparkColors.ink)
                .lineLimit(3...6)
                .padding(.horizontal, SparkSpacing.md)
                .padding(.vertical, 14)
                .frame(minHeight: 60, alignment: .topLeading)
                .background(SparkColors.card)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .sparkSoftShadow()
                .padding(.top, 10)
        }
        .padding(.top, SparkSpacing.lg)
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

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
            .foregroundStyle(SparkColors.inkSoft)
    }

    private func resetFields() {
        if let editing {
            title = editing.title
            category = editing.category
            customCategory = editing.customCategory ?? ""
            date = Date(timeIntervalSince1970: TimeInterval(editing.date) / 1000)
            time = editing.time
            recurring = editing.recurring
            reminderEnabled = editing.reminderEnabled ?? true
            daysBefore = editing.reminderDaysBefore
            notes = editing.notes ?? ""
        } else {
            title = ""
            category = initialCategory
            customCategory = ""
            date = Date()
            time = nil
            recurring = DatesContent.defaultRecurrence(for: initialCategory)
            reminderEnabled = true
            daysBefore = 1
            notes = ""
        }
        showDatePicker = false
        showTimePicker = false
        notice = nil
        saving = false
        originalSnapshot = currentSnapshot()
    }

    private func requestClose() {
        if hasUnsavedChanges {
            showDiscardAlert = true
        } else {
            onClose()
        }
    }

    private func currentSnapshot() -> DateDraftSnapshot {
        DateDraftSnapshot(
            title: title,
            category: category,
            customCategory: customCategory,
            dateMs: DatesContent.toMidnight(date),
            time: time,
            recurring: recurring,
            reminderEnabled: reminderEnabled,
            daysBefore: daysBefore,
            notes: notes
        )
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedTitle = trimmedTitle.isEmpty ? editing?.title.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" : trimmedTitle
        guard !resolvedTitle.isEmpty, !saving else { return }

        if category == .custom && customCategory.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            notice = "Give your custom category a little name first 💗"
            return
        }

        saving = true
        let input = DateComposerInput(
            title: resolvedTitle,
            category: category,
            customCategory: category == .custom ? customCategory.trimmingCharacters(in: .whitespacesAndNewlines) : nil,
            date: DatesContent.toMidnight(date),
            time: time,
            recurring: recurring,
            reminderEnabled: reminderEnabled,
            reminderDaysBefore: daysBefore,
            notes: notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        Task {
            let permissionDenied = await onSave(input)
            await MainActor.run {
                if permissionDenied {
                    notice = "Saved! Reminders are off right now, so I can't nudge you. Tap the gear to turn them on anytime. 💗"
                    saving = false
                    Task {
                        try? await Task.sleep(for: .seconds(2.6))
                        await MainActor.run { onClose() }
                    }
                } else {
                    onClose()
                }
            }
        }
    }
}

private struct DateDraftSnapshot: Equatable {
    var title: String
    var category: DateCategory
    var customCategory: String
    var dateMs: Int64
    var time: EventTime?
    var recurring: DateRecurrence
    var reminderEnabled: Bool
    var daysBefore: Int
    var notes: String

    static let empty = DateDraftSnapshot(
        title: "",
        category: .birthday,
        customCategory: "",
        dateMs: 0,
        time: nil,
        recurring: .yearly,
        reminderEnabled: true,
        daysBefore: 1,
        notes: ""
    )
}

struct DateComposerInput {
    let title: String
    let category: DateCategory
    let customCategory: String?
    let date: Int64
    let time: EventTime?
    let recurring: DateRecurrence
    let reminderEnabled: Bool
    let reminderDaysBefore: Int
    let notes: String?
}

private struct DatesFlowLayout: Layout {
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
