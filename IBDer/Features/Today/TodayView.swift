import SwiftUI

/// The home screen: which day, how to record, and what was recorded. Facts only — no score, no
/// verdict (ADR-0009). The date and the entry points stay put while the timeline scrolls.
struct TodayView: View {
    let model: RecordsModel
    let biologic: BiologicModel
    let profile: ProfileModel
    @State private var sheet: Sheet?
    @State private var showingBiologic = false

    enum Sheet: Identifiable {
        case create(RecordKind)
        case edit(RecordedEvent)

        var id: String {
            switch self {
            case let .create(kind): "create-\(kind.rawValue)"
            case let .edit(event): "edit-\(event.id)"
            }
        }
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh-Hans")
        formatter.setLocalizedDateFormatFromTemplate("MMMd EEEE")
        return formatter
    }()

    var body: some View {
        VStack(spacing: 0) {
            header
            entries
            if biologic.plan != nil {
                BiologicCard(model: biologic) { showingBiologic = true }
                    .padding(.horizontal, DesignTokens.Spacing.regular)
                    .padding(.bottom, DesignTokens.Spacing.medium)
            }
            timeline
        }
        .background(DesignTokens.Color.background)
        .task { await model.loadIfNeeded() }
        .overlay(alignment: .bottom) { undoBar }
        .animation(.snappy(duration: 0.22), value: model.lastDeleted?.id)
        .sheet(item: $sheet) { sheetView(for: $0) }
        .sheet(isPresented: $showingBiologic) {
            BiologicPlanView(model: biologic, profile: profile)
        }
        .alert("error.title", isPresented: failurePresented) {
            Button("common.ok", role: .cancel) { model.failure = nil }
        } message: {
            Text(model.failure ?? "")
        }
    }

    private var failurePresented: Binding<Bool> {
        Binding(
            get: { model.failure != nil },
            set: {
                if !$0 {
                    model.failure = nil
                }
            }
        )
    }

    private var isToday: Bool {
        Calendar.current.isDateInToday(model.day)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            arrow("chevron.left", label: "today.previousDay", identifier: "today.previousDay") {
                Task { await model.step(-1) }
            }
            Spacer(minLength: 0)
            VStack(spacing: 2) {
                Text(Self.dayFormatter.string(from: model.day))
                    .font(DesignTokens.Typography.title)
                    .foregroundStyle(DesignTokens.Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                Text(model.day, format: .dateTime.year())
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
            .accessibilityElement(children: .combine)
            .accessibilityIdentifier("today.date")
            Spacer(minLength: 0)
            arrow("chevron.right", label: "today.nextDay", identifier: "today.nextDay") {
                Task { await model.step(1) }
            }
            .disabled(isToday)
            .opacity(isToday ? 0.3 : 1)
        }
        .padding(.horizontal, DesignTokens.Spacing.regular)
        .padding(.top, DesignTokens.Spacing.small)
        // The date is display text, not body text: it may scale, but it must not push the entries off screen.
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
    }

    private func arrow(
        _ symbol: String,
        label: LocalizedStringKey,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.headline)
                .foregroundStyle(DesignTokens.Color.accent)
                .frame(width: DesignTokens.Layout.minimumTouchTarget, height: DesignTokens.Layout.minimumTouchTarget)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(label))
        .accessibilityIdentifier(identifier)
    }

    // MARK: - Entry points

    private var entries: some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            EntryChip(symbol: "drop.fill", titleKey: "entry.toilet", identifier: "entry.toilet") {
                sheet = .create(.toilet)
            }
            EntryChip(symbol: "fork.knife", titleKey: "entry.meal", identifier: "entry.meal") {
                sheet = .create(.meal)
            }
            EntryChip(symbol: "pills.fill", titleKey: "entry.medication", identifier: "entry.medication") {
                sheet = .create(.medication)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.regular)
        .padding(.vertical, DesignTokens.Spacing.medium)
    }

    // MARK: - Timeline

    @ViewBuilder private var timeline: some View {
        if model.events.isEmpty {
            VStack(spacing: DesignTokens.Spacing.small) {
                Text("today.empty.title")
                    .font(DesignTokens.Typography.headline)
                    .foregroundStyle(DesignTokens.Color.textPrimary)
                    .accessibilityIdentifier("today.empty.title")
                Text("today.empty.body")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, DesignTokens.Spacing.large)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(Array(model.events.enumerated()), id: \.element.id) { index, event in
                    TimelineRow(event: event, isLast: index == model.events.count - 1)
                        .listRowInsets(EdgeInsets(
                            top: 0,
                            leading: DesignTokens.Spacing.regular,
                            bottom: 0,
                            trailing: DesignTokens.Spacing.regular
                        ))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .contentShape(Rectangle())
                        .onTapGesture { sheet = .edit(event) }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task { await model.delete(event) }
                            } label: {
                                Label("common.delete", systemImage: "trash")
                            }
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                sheet = .edit(event)
                            } label: {
                                Label("common.edit", systemImage: "pencil")
                            }
                            .tint(DesignTokens.Color.accent)
                        }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
    }

    // MARK: - Undo

    @ViewBuilder private var undoBar: some View {
        if let deleted = model.lastDeleted {
            HStack(spacing: DesignTokens.Spacing.medium) {
                Text("today.deleted.fact")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Spacer(minLength: 0)
                Button("common.undo") {
                    Task { await model.undoDelete() }
                }
                .font(DesignTokens.Typography.headline)
                .foregroundStyle(.white)
                .accessibilityIdentifier("today.undo")
                .padding(.leading, DesignTokens.Spacing.small)
                .opacity(deleted.isDeleted ? 1 : 0)
            }
            .padding(.horizontal, DesignTokens.Spacing.regular)
            .padding(.vertical, DesignTokens.Spacing.medium)
            .background(DesignTokens.Color.ink, in: Capsule())
            .padding(.horizontal, DesignTokens.Spacing.regular)
            .padding(.bottom, DesignTokens.Spacing.small)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    // MARK: - Sheets

    @ViewBuilder private func sheetView(for state: Sheet) -> some View {
        switch state {
        case let .create(kind):
            switch kind {
            case .toilet:
                ToiletSheet(day: model.day, editing: nil) { toilet, happenedAt in
                    await model.save(toilet: toilet, at: happenedAt, editing: nil)
                }
            case .meal:
                MealSheet(day: model.day, editing: nil) { meal, happenedAt in
                    await model.save(meal: meal, at: happenedAt, editing: nil)
                }
            case .medication:
                MedicationSheet(
                    day: model.day,
                    editing: nil,
                    recent: model.recentMedications
                ) { medication, happenedAt in
                    await model.save(medication: medication, at: happenedAt, editing: nil)
                }
            }
        case let .edit(event):
            switch event.payload {
            case .toilet:
                ToiletSheet(day: model.day, editing: event) { toilet, happenedAt in
                    await model.save(toilet: toilet, at: happenedAt, editing: event)
                }
            case .meal:
                MealSheet(day: model.day, editing: event) { meal, happenedAt in
                    await model.save(meal: meal, at: happenedAt, editing: event)
                }
            case .medication:
                MedicationSheet(
                    day: model.day,
                    editing: event,
                    recent: model.recentMedications
                ) { medication, happenedAt in
                    await model.save(medication: medication, at: happenedAt, editing: event)
                }
            }
        }
    }
}
