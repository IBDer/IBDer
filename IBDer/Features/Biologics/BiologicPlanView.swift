import SwiftUI

/// Everything about the biologic plan: the next dose, its checklist, the doses after it, and the two
/// actions the patient has — record what happened, or move one appointment.
struct BiologicPlanView: View {
    let model: BiologicModel
    let profile: ProfileModel

    @Environment(\.dismiss) private var dismiss
    @State private var showingRecord = false
    @State private var showingPostpone = false

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
            }
        }
        .sheet(isPresented: $showingRecord) {
            if let dose = model.nextDose {
                RecordDoseView(model: model, dose: dose) { showingRecord = false }
            }
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
                        Button {
                            showingPostpone = true
                        } label: {
                            Text("biologic.postpone")
                                .font(DesignTokens.Typography.headline)
                                .foregroundStyle(DesignTokens.Color.accent)
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(
                                    DesignTokens.Color.surface,
                                    in: RoundedRectangle(cornerRadius: DesignTokens.Radius.control)
                                )
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("biologic.postpone")
                    }
                } else {
                    Text("biologic.noNextDose")
                        .font(DesignTokens.Typography.body)
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                }

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
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.small) {
                Text(dose.date, format: .dateTime.month().day().hour().minute())
                    .font(DesignTokens.Typography.title)
                    .foregroundStyle(DesignTokens.Color.textPrimary)
                Spacer()
                BiologicText.due(dose)
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(
                        BiologicSchedule.overdueDays(for: dose, now: .now) == nil
                            ? DesignTokens.Color.textSecondary
                            : DesignTokens.Color.alert
                    )
            }
            HStack(spacing: DesignTokens.Spacing.small) {
                Text(dose.route == .intravenous ? "biologic.route.intravenous" : "biologic.route.subcutaneous")
                Text(verbatim: "·")
                BiologicText.amount(dose.amountMilligrams)
            }
            .font(DesignTokens.Typography.caption)
            .foregroundStyle(DesignTokens.Color.textSecondary)

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
                        Text(LocalizedStringKey("biologic.checklist.\(item.key)"))
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
