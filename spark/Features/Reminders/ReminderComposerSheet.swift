//
//  ReminderComposerSheet.swift
//  Spark
//
//  Purpose:
//  Composer sheet for creating and editing reminders.
//
//  Responsibilities:
//  • Edits reminder text, schedule, category, and recurrence.
//

import SwiftUI

struct ReminderComposerSheet: View {
    let editing: Reminder?
    let categories: [ReminderCategory]
    let onClose: () -> Void
    let onSave: (ReminderInput) -> Void
    let onCreateCategory: (String, String) -> ReminderCategory
    let onRequestDeleteCategory: (ReminderCategory) -> Void

    @State private var title = ""
    @State private var emoji: String?
    @State private var categoryId = ReminderCategoryDefaults.otherCategoryID
    @State private var editingCategories = false
    @State private var startDate = Date()
    @State private var time = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
    @State private var scheduleType: ReminderScheduleType = .everyDay
    @State private var weekdays: [Int] = []
    @State private var showTimePicker = false
    @State private var showDatePicker = false
    @State private var categoryComposerOpen = false
    @State private var originalSnapshot = ReminderDraftSnapshot.empty
    @State private var showDiscardAlert = false

    private var hasUnsavedChanges: Bool {
        currentSnapshot() != originalSnapshot
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    categorySection
                    titleSection
                    scheduleSection
                    dateSection
                    timeSection
                    weekdaySection
                    validationSection
                }
                .padding(.horizontal, SparkSpacing.section)
                .padding(.bottom, 44)
            }
            .scrollIndicators(.hidden)
            .background(SparkColors.cream)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editing == nil ? "New reminder" : "Edit reminder")
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
                    Button(editing == nil ? "Save" : "Save") {
                        save()
                    }
                    .font(SparkTypography.font(.bodyBold, size: 16, relativeTo: .body))
                    .disabled(!canSave)
                    .accessibilityLabel(editing == nil ? "Save reminder" : "Save changes")
                }
            }
        }
        .unsavedChangesDismissDisabled(hasUnsavedChanges)
        .discardChangesAlert(
            isPresented: $showDiscardAlert,
            message: UnsavedChangesGuard.formMessage("reminder"),
            onDiscard: onClose
        )
        .sheet(isPresented: $categoryComposerOpen) {
            CategoryComposerSheet(
                onClose: { categoryComposerOpen = false },
                onCreate: { label, emoji in
                    let category = onCreateCategory(label, emoji)
                    categoryId = category.id
                    categoryComposerOpen = false
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
        .onAppear(perform: resetFields)
        .onChange(of: editing?.id) { _, _ in resetFields() }
        .onChange(of: categories.map(\.id)) { _, _ in
            if categoryId != ReminderCategoryDefaults.otherCategoryID,
               !categories.contains(where: { $0.id == categoryId }) {
                categoryId = ReminderCategoryDefaults.otherCategoryID
            }
        }
        .onChange(of: scheduleType) { _, newValue in
            if newValue != .selectedDays {
                weekdays = []
            }
        }
    }

    private var resolvedTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
        return editing?.title.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    }

    private var startDateMs: Int64 {
        ReminderScheduleCalculator.startOfDayMs(for: startDate)
    }

    private var combinedDateTime: Date {
        ReminderScheduleCalculator.combine(startDayMs: startDateMs, time: ReminderTime(
            hour: Calendar.current.component(.hour, from: time),
            minute: Calendar.current.component(.minute, from: time)
        ))
    }

    private var formattedTime: String {
        RemindersContent.formatTime(
            hour: Calendar.current.component(.hour, from: time),
            minute: Calendar.current.component(.minute, from: time)
        )
    }

    private var validationMessage: String? {
        guard !resolvedTitle.isEmpty || editing != nil else { return nil }

        if scheduleType == .selectedDays && weekdays.isEmpty {
            return "Pick at least one day."
        }

        if scheduleType == .oneTime && combinedDateTime <= Date() {
            return "Choose a future date and time."
        }

        return nil
    }

    private var canSave: Bool {
        !resolvedTitle.isEmpty && validationMessage == nil
    }

    private var dateSectionLabel: String {
        scheduleType == .oneTime ? "DATE" : "STARTING ON"
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                sectionLabel("CATEGORY")
                Spacer()
                Button {
                    SparkHaptics.lightImpact()
                    editingCategories.toggle()
                } label: {
                    Text(editingCategories ? "Done" : "Edit")
                        .font(SparkTypography.font(.bodyBold, size: 12.5, relativeTo: .footnote))
                        .foregroundStyle(SparkColors.lavender)
                }
                .buttonStyle(.plain)
            }
            .padding(.top, SparkSpacing.sm)

            RemindersFlowLayout(spacing: 8, rowSpacing: 8) {
                ForEach(categories) { category in
                    categoryChip(category)
                }
                addCategoryChip
            }
            .padding(.top, 10)
        }
    }

    private func categoryChip(_ category: ReminderCategory) -> some View {
        let active = category.id == categoryId
        let deletable = editingCategories && category.id != ReminderCategoryDefaults.otherCategoryID

        return HStack(spacing: 6) {
            Button {
                SparkHaptics.lightImpact()
                categoryId = category.id
            } label: {
                HStack(spacing: 6) {
                    Text(category.emoji)
                        .font(.system(size: 15))
                    Text(category.label)
                        .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                        .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
                }
            }
            .buttonStyle(.plain)

            if deletable {
                Button {
                    onRequestDeleteCategory(category)
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
                        .frame(width: 20, height: 20)
                        .background(active ? Color.white.opacity(0.3) : SparkColors.lavenderSoft)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Remove category \(category.label)")
            }
        }
        .padding(.leading, SparkSpacing.sm)
        .padding(.trailing, deletable ? 6 : SparkSpacing.sm)
        .padding(.vertical, 9)
        .background(active ? category.color : SparkColors.card)
        .clipShape(Capsule())
        .sparkSoftShadow()
        .accessibilityElement(children: .combine)
        .accessibilityLabel(category.label)
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    private var addCategoryChip: some View {
        Button {
            SparkHaptics.lightImpact()
            categoryComposerOpen = true
        } label: {
            HStack(spacing: 5) {
                Image(systemName: "plus")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(SparkColors.lavender)
                Text("New")
                    .font(SparkTypography.font(.bodyBold, size: 14, relativeTo: .subheadline))
                    .foregroundStyle(SparkColors.lavender)
            }
            .padding(.horizontal, SparkSpacing.sm)
            .padding(.vertical, 9)
            .background(SparkColors.card)
            .clipShape(Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(SparkColors.lavenderSoft, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("New category")
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("WHAT SHOULD I REMIND YOU?")
            TextField("e.g. Take medicine", text: $title)
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

    private var scheduleSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("HOW OFTEN?")
            HStack(spacing: 8) {
                scheduleButton(.oneTime, label: "One time")
                scheduleButton(.everyDay, label: "Every day")
                scheduleButton(.selectedDays, label: "Certain days")
            }
            .padding(.top, 10)
        }
        .padding(.top, SparkSpacing.lg)
    }

    private func scheduleButton(_ value: ReminderScheduleType, label: String) -> some View {
        let active = scheduleType == value

        return Button {
            SparkHaptics.lightImpact()
            scheduleType = value
        } label: {
            Text(label)
                .font(SparkTypography.font(.bodyBold, size: 13, relativeTo: .footnote))
                .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, SparkSpacing.sm)
                .background(active ? AnyShapeStyle(SparkTheme.gradient(.dream)) : AnyShapeStyle(SparkColors.card))
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
                .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel(dateSectionLabel)
            Button {
                SparkHaptics.lightImpact()
                showDatePicker.toggle()
            } label: {
                HStack(spacing: SparkSpacing.xs) {
                    Image(systemName: "calendar")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SparkColors.lavender)
                    Text(startDate.formatted(date: .abbreviated, time: .omitted))
                        .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                        .foregroundStyle(SparkColors.ink)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, SparkSpacing.md)
                .padding(.vertical, 14)
                .background(SparkColors.lavenderSoft)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.top, 10)
            .accessibilityLabel("\(dateSectionLabel), \(startDate.formatted(date: .long, time: .omitted))")

            if showDatePicker {
                DatePicker(
                    "Reminder date",
                    selection: $startDate,
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
            sectionLabel("WHAT TIME?")
            Button(action: openTimePicker) {
                HStack(spacing: SparkSpacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(SparkColors.lavender)
                    Text(formattedTime)
                    .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                    .foregroundStyle(SparkColors.ink)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, SparkSpacing.md)
                .padding(.vertical, 14)
                .background(SparkColors.lavenderSoft)
                .clipShape(RoundedRectangle(cornerRadius: SparkRadius.md, style: .continuous))
            }
            .buttonStyle(.plain)
            .padding(.top, 10)
            .accessibilityLabel("Reminder time, \(formattedTime)")

            if showTimePicker {
                DatePicker(
                    "Reminder time",
                    selection: $time,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .frame(height: 180)
                .clipped()
                .padding(.top, SparkSpacing.xs)
            }
        }
        .padding(.top, SparkSpacing.lg)
    }

    @ViewBuilder
    private var weekdaySection: some View {
        if scheduleType == .selectedDays {
            VStack(alignment: .leading, spacing: 0) {
                sectionLabel("WHICH DAYS?")
                HStack {
                    ForEach(0..<7, id: \.self) { weekday in
                        weekdayButton(weekday)
                    }
                }
                .padding(.top, 10)
            }
            .padding(.top, SparkSpacing.lg)
        }
    }

    private func weekdayButton(_ weekday: Int) -> some View {
        let active = weekdays.contains(weekday)

        return Button {
            SparkHaptics.lightImpact()
            if active {
                weekdays.removeAll { $0 == weekday }
            } else {
                weekdays.append(weekday)
            }
        } label: {
            Text(RemindersContent.dayLetters[weekday])
                .font(SparkTypography.font(.bodyBold, size: 15, relativeTo: .body))
                .foregroundStyle(active ? SparkColors.white : SparkColors.inkSoft)
                .frame(width: 40, height: 40)
                .background(active ? SparkColors.lavender : SparkColors.card)
                .clipShape(Circle())
                .sparkSoftShadow()
        }
        .buttonStyle(.plain)
        .accessibilityLabel(RemindersContent.dayShort[weekday])
        .accessibilityAddTraits(active ? .isSelected : [])
    }

    @ViewBuilder
    private var validationSection: some View {
        if let validationMessage {
            Text(validationMessage)
                .font(SparkTypography.font(.body, size: 13, relativeTo: .footnote))
                .foregroundStyle(SparkColors.pink)
                .padding(.top, SparkSpacing.md)
        }
    }

    private func requestClose() {
        if hasUnsavedChanges {
            showDiscardAlert = true
        } else {
            onClose()
        }
    }

    private func currentSnapshot() -> ReminderDraftSnapshot {
        ReminderDraftSnapshot(
            title: title,
            emoji: emoji,
            categoryId: categoryId,
            startDateMs: startDateMs,
            timeHour: Calendar.current.component(.hour, from: time),
            timeMinute: Calendar.current.component(.minute, from: time),
            scheduleType: scheduleType,
            weekdays: weekdays.sorted()
        )
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(SparkTypography.font(.bodyExtra, size: 13, relativeTo: .footnote))
            .foregroundStyle(SparkColors.inkSoft)
    }

    private func resetFields() {
        if let editing {
            title = editing.title
            emoji = editing.emoji
            let exists = categories.contains { $0.id == editing.categoryId }
            categoryId = exists && editing.categoryId != nil
                ? editing.categoryId!
                : ReminderCategoryDefaults.otherCategoryID
            startDate = ReminderScheduleCalculator.date(fromStartDayMs: editing.startDate)
            var components = DateComponents()
            components.hour = editing.time.hour
            components.minute = editing.time.minute
            time = Calendar.current.date(from: components) ?? time
            scheduleType = editing.scheduleType
            weekdays = editing.weekdays ?? []
        } else {
            title = ""
            emoji = nil
            categoryId = ReminderCategoryDefaults.otherCategoryID
            startDate = Date()
            time = Calendar.current.date(from: DateComponents(hour: 8, minute: 0)) ?? Date()
            scheduleType = .everyDay
            weekdays = []
        }
        showTimePicker = true
        showDatePicker = false
        editingCategories = false
        originalSnapshot = currentSnapshot()
    }

    private func openTimePicker() {
        SparkHaptics.lightImpact()
        showTimePicker = true
    }

    private func save() {
        guard canSave else { return }

        let hour = Calendar.current.component(.hour, from: time)
        let minute = Calendar.current.component(.minute, from: time)
        onSave(
            ReminderInput(
                title: resolvedTitle,
                emoji: emoji,
                categoryId: categoryId,
                time: ReminderTime(hour: hour, minute: minute),
                scheduleType: scheduleType,
                startDate: startDateMs,
                weekdays: scheduleType == .selectedDays ? weekdays : nil,
                enabled: true
            )
        )
    }
}

private struct ReminderDraftSnapshot: Equatable {
    var title: String
    var emoji: String?
    var categoryId: String
    var startDateMs: Int64
    var timeHour: Int
    var timeMinute: Int
    var scheduleType: ReminderScheduleType
    var weekdays: [Int]

    static let empty = ReminderDraftSnapshot(
        title: "",
        emoji: nil,
        categoryId: ReminderCategoryDefaults.otherCategoryID,
        startDateMs: 0,
        timeHour: 8,
        timeMinute: 0,
        scheduleType: .everyDay,
        weekdays: []
    )
}

private struct RemindersFlowLayout: Layout {
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
