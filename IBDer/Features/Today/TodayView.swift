import SwiftUI

/// The home screen. Three things, in this order: which day it is, what was recorded,
/// and the ways to record more. Facts only — no score, no verdict (ADR-0009).
struct TodayView: View {
    @State private var day: Date
    @State private var events: [RecordedEvent]

    /// `day` is injectable so a snapshot can pin the date; otherwise every baseline changes daily.
    init(events: [RecordedEvent] = RecordedEvent.launchSample, day: Date = .now) {
        _events = State(initialValue: events)
        _day = State(initialValue: day)
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh-Hans")
        formatter.setLocalizedDateFormatFromTemplate("MMMd EEEE")
        return formatter
    }()

    var body: some View {
        VStack(spacing: DesignTokens.Spacing.regular) {
            dayHeader
            eventSection
            Spacer(minLength: 0)
            entryRow
            DashedActionRow(titleKey: "confirm.title", hintKey: "confirm.subtitle", symbol: "checklist") {}
        }
        .padding(.horizontal, DesignTokens.Spacing.regular)
        .padding(.top, DesignTokens.Spacing.small)
        .padding(.bottom, DesignTokens.Spacing.regular)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(DesignTokens.Color.background)
    }

    private var dayHeader: some View {
        HStack {
            dayArrow(symbol: "chevron.left", labelKey: "today.previousDay") {
                day = Calendar.current.date(byAdding: .day, value: -1, to: day) ?? day
            }
            Spacer()
            VStack(spacing: 2) {
                Text(Self.dayFormatter.string(from: day))
                    .font(DesignTokens.Typography.title)
                    .foregroundStyle(DesignTokens.Color.textPrimary)
                Text(day, format: .dateTime.year())
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
            Spacer()
            dayArrow(symbol: "chevron.right", labelKey: "today.nextDay") {
                day = Calendar.current.date(byAdding: .day, value: 1, to: day) ?? day
            }
            .disabled(Calendar.current.isDateInToday(day))
            .opacity(Calendar.current.isDateInToday(day) ? 0.3 : 1)
        }
        .padding(.top, DesignTokens.Spacing.small)
    }

    private func dayArrow(symbol: String, labelKey: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.headline)
                .foregroundStyle(DesignTokens.Color.accent)
                .frame(width: DesignTokens.Layout.minimumTouchTarget, height: DesignTokens.Layout.minimumTouchTarget)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(labelKey))
    }

    @ViewBuilder private var eventSection: some View {
        if events.isEmpty {
            VStack(spacing: DesignTokens.Spacing.small) {
                Spacer(minLength: DesignTokens.Spacing.xLarge)
                Text("today.empty.title")
                    .font(DesignTokens.Typography.headline)
                    .accessibilityIdentifier("today.empty.title")
                    .foregroundStyle(DesignTokens.Color.textPrimary)
                Text("today.empty.body")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
                    .multilineTextAlignment(.center)
                Spacer(minLength: DesignTokens.Spacing.xLarge)
            }
            .frame(maxWidth: .infinity)
        } else {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
                Text("today.section.events")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
                    .padding(.leading, DesignTokens.Spacing.xSmall)
                ForEach(events) { event in
                    EventRow(event: event)
                }
            }
        }
    }

    private var entryRow: some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            EntryChip(symbol: "drop.fill", titleKey: "entry.toilet", identifier: "entry.toilet") {}
            EntryChip(symbol: "fork.knife", titleKey: "entry.meal", identifier: "entry.meal") {}
            EntryChip(symbol: "pills.fill", titleKey: "entry.medication", identifier: "entry.medication") {}
            EntryChip(symbol: "syringe.fill", titleKey: "entry.infusion", identifier: "entry.infusion") {}
        }
    }
}

/// One recorded fact. No interpretation is added here on purpose.
struct EventRow: View {
    let event: RecordedEvent

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.medium) {
            Image(systemName: event.symbol)
                .font(.body)
                .foregroundStyle(DesignTokens.Color.accent)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 2) {
                Text(event.titleKey)
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Color.textPrimary)
                Text(event.timeText)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
            Spacer(minLength: DesignTokens.Spacing.small)
            if event.isPartial {
                Text("event.partial")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
        }
        .padding(DesignTokens.Spacing.medium)
        .frame(minHeight: DesignTokens.Layout.minimumTouchTarget)
        .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
    }
}

#Preview("With records") {
    TodayView()
}

#Preview("Empty day") {
    TodayView(events: [])
}
