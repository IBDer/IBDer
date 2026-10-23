import SwiftUI

/// Everything about the biologic plan: the next dose, its checklist, the doses after it, and the two
/// actions the patient has — record what happened, or move one appointment.
struct BiologicPlanView: View {
    let model: BiologicModel
    let profile: ProfileModel

    @Environment(\.dynamicTypeSize) private var typeSize

    @Environment(\.dismiss) private var dismiss
    @State private var showingRecord = false
    @State private var showingPostpone = false
    @State private var showingInterval = false
    @State private var showingCancel = false

    var body: some View {
        NavigationStack {
            Group {
                if let plan = model.plan {
                    planList(plan)
                } else {
                    StartPlanView(model: model, profile: profile) { dismiss() }
                }
            }
            .background(DesignTokens.Color.background)
            .navigationTitle("biologic.title")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("common.close") { dismiss() }
                }
                if model.plan != nil {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("biologic.interval.title") { showingInterval = true }
                            .accessibilityIdentifier("biologic.interval")
                    }
                }
            }
        }
        .sheet(isPresented: $showingRecord) {
            if let dose = model.nextDose {
                RecordDoseView(model: model, dose: dose) { showingRecord = false }
            }
        }
        .sheet(isPresented: $showingCancel) {
            CancelAppointmentView(model: model) { showingCancel = false }
        }
        .sheet(isPresented: $showingInterval) {
            ChangeIntervalView(model: model) { showingInterval = false }
        }
        .sheet(isPresented: $showingPostpone) {
            if let dose = model.nextDose {
                PostponeView(model: model, dose: dose) { showingPostpone = false }
            }
        }
    }

    private func planList(_ plan: BiologicPlan) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                if let dose = model.nextDose {
                    nextDoseCard(dose)
                    checklistCard(dose)
                    HStack(spacing: DesignTokens.Spacing.small) {
                        PrimaryButton(titleKey: "biologic.record", identifier: "biologic.record") {
                            showingRecord = true
                        }
                        Menu {
                            Button("biologic.postpone") { showingPostpone = true }
                            Button("biologic.cancel") { showingCancel = true }
                        } label: {
                            Text("biologic.more")
                                .font(DesignTokens.Typography.headline)
                                .foregroundStyle(DesignTokens.Color.accent)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    DesignTokens.Color.surface,
                                    in: RoundedRectangle(cornerRadius: DesignTokens.Radius.control)
                                )
                        }
                        .accessibilityIdentifier("biologic.more")
                    }
                } else {
                    Text("biologic.noNextDose")
                        .font(DesignTokens.Typography.body)
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                }

                remindersCard

                upcoming(model.state.doses)

                if let regimen = model.regimen {
                    Text(LocalizedStringKey(regimen.regimenKey))
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                }
            }
            .padding(DesignTokens.Spacing.regular)
        }
    }

    private func nextDoseCard(_ dose: PlannedDose) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            Text("biologic.nextDose")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
            // At accessibility sizes the two labels need their own lines; side by side they crush
            // each other into fragments.
            let due = BiologicText.due(dose)
                .font(DesignTokens.Typography.body)
                .foregroundStyle(
                    BiologicSchedule.overdueDays(for: dose, now: .now) == nil
                        ? DesignTokens.Color.textSecondary
                        : DesignTokens.Color.alert
                )
            let when = Text(dose.date, format: .dateTime.month().day().hour().minute())
                .font(DesignTokens.Typography.title)
                .foregroundStyle(DesignTokens.Color.textPrimary)

            if typeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
                    when
                    due
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.small) {
                    when
                    Spacer()
                    due
                }
            }
            routeLine(dose)

            if let reason = dose.postponementReason {
                Text(reason)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
        }
        .padding(DesignTokens.Spacing.regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
    }

    @ViewBuilder private func routeLine(_ dose: PlannedDose) -> some View {
        let route: LocalizedStringKey = dose.route == .intravenous
            ? "biologic.route.intravenous"
            : "biologic.route.subcutaneous"
        if typeSize.isAccessibilitySize {
            VStack(alignment: .leading, spacing: 2) {
                Text(route)
                BiologicText.amount(dose.amountMilligrams)
            }
            .font(DesignTokens.Typography.caption)
            .foregroundStyle(DesignTokens.Color.textSecondary)
        } else {
            HStack(spacing: DesignTokens.Spacing.small) {
                Text(route)
                Text(verbatim: "·")
                BiologicText.amount(dose.amountMilligrams)
            }
            .font(DesignTokens.Typography.caption)
            .foregroundStyle(DesignTokens.Color.textSecondary)
        }
    }

    private func checklistCard(_ dose: PlannedDose) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            Text("biologic.checklist")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
            ForEach(dose.checklist) { item in
                Button {
                    Task { await model.toggleChecklist(item: item, in: dose) }
                } label: {
                    HStack(spacing: DesignTokens.Spacing.small) {
                        Image(systemName: item.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(item.isDone ? DesignTokens.Color.accent : DesignTokens.Color.textSecondary)
                        Text(Self.checklistTitle(item.key))
                            .font(DesignTokens.Typography.body)
                            .foregroundStyle(DesignTokens.Color.textPrimary)
                        Spacer(minLength: 0)
                    }
                    .frame(minHeight: DesignTokens.Layout.minimumTouchTarget)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("checklist.\(item.key)")
            }
        }
        .padding(DesignTokens.Spacing.regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
    }

    private var remindersCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            Text("biologic.reminders")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
            ForEach([14, 7, 1], id: \.self) { days in
                Toggle(isOn: Binding(
                    get: { model.state.reminderLeadTimes.contains(days) },
                    set: { _ in Task { await model.toggleLeadTime(days) } }
                )) {
                    Text(Self.leadTimeTitle(days))
                        .font(DesignTokens.Typography.body)
                        .foregroundStyle(DesignTokens.Color.textPrimary)
                }
                .tint(DesignTokens.Color.accent)
                .accessibilityIdentifier("reminder.lead.\(days)")
            }
            if !model.remindersAllowed {
                Text("biologic.reminders.denied")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
        }
        .padding(DesignTokens.Spacing.regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
    }

    /// Compile-time keys only: a key built from a runtime string does not localise.
    private static func checklistTitle(_ key: String) -> LocalizedStringKey {
        switch key {
        case "bloodTest": "biologic.checklist.bloodTest"
        case "timeAndPlace": "biologic.checklist.timeAndPlace"
        default: "biologic.checklist"
        }
    }

    private static func leadTimeTitle(_ days: Int) -> LocalizedStringKey {
        switch days {
        case 14: "biologic.reminder.lead.14"
        case 7: "biologic.reminder.lead.7"
        default: "biologic.reminder.lead.1"
        }
    }

    private func upcoming(_ doses: [PlannedDose]) -> some View {
        let planned = doses.filter { $0.status == .planned }.sorted { $0.date < $1.date }.dropFirst()
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            if !planned.isEmpty {
                Text("biologic.upcoming")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
                ForEach(Array(planned)) { dose in
                    HStack {
                        Text(dose.date, format: .dateTime.year().month().day())
                            .font(DesignTokens.Typography.body)
                            .foregroundStyle(DesignTokens.Color.textPrimary)
                        Spacer()
                        BiologicText.amount(dose.amountMilligrams)
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Color.textSecondary)
                    }
                    .frame(minHeight: DesignTokens.Layout.minimumTouchTarget)
                }
            }
        }
        .padding(DesignTokens.Spacing.regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
    }
}
