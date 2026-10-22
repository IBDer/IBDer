import Charts
import SwiftUI

/// The trends tab, laid out like the system's own fitness history: one segmented range control, the
/// four counts as tiles, one aligned chart for the selected metric, and the stool forms as a ring.
struct TrendsView: View {
    let model: RecordsModel

    @State private var range: TrendRange = .week
    @State private var metric: TrendMetric = .bowelMovements
    @State private var anchor = Date.now
    @State private var events: [RecordedEvent] = []
    @State private var selected: TrendBucket?

    private var buckets: [TrendBucket] {
        TrendAggregation.buckets(for: range, containing: anchor, events: events, metric: metric)
    }

    private var period: (start: Date, end: Date) {
        TrendAggregation.period(for: range, containing: anchor)
    }

    private var periodEvents: [RecordedEvent] {
        events.filter { !$0.isDeleted && $0.happenedAt >= period.start && $0.happenedAt < period.end }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.large) {
                    rangeControl
                    periodHeader
                    tiles
                    chartCard
                    ringCard
                }
                .padding(.horizontal, DesignTokens.Spacing.regular)
                .padding(.bottom, DesignTokens.Spacing.large)
            }
            .background(DesignTokens.Color.background)
            .contentMargins(.bottom, 96, for: .scrollContent)
            .navigationTitle("tab.trends")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(DesignTokens.Color.background, for: .navigationBar)
            .task(id: loadKey) { await load() }
            .sheet(item: $selected) { bucket in
                BucketDetailView(bucket: bucket, events: events)
            }
        }
    }

    private var loadKey: String {
        "\(range.rawValue)-\(anchor.timeIntervalSince1970)-\(metric.rawValue)"
    }

    private var rangeControl: some View {
        Picker("range", selection: $range) {
            ForEach(TrendRange.allCases) { item in
                Text(rangeTitle(item)).tag(item)
            }
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("trends.range")
    }

    private var periodHeader: some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            Button { step(-1) } label: {
                Image(systemName: "chevron.left")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DesignTokens.Color.accent)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .accessibilityIdentifier("trends.previous")

            Text(periodText)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
                .accessibilityIdentifier("trends.period")

            Button { step(1) } label: {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(canStepForward ? DesignTokens.Color.accent : DesignTokens.Color.textSecondary
                        .opacity(0.3))
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .disabled(!canStepForward)
            .accessibilityIdentifier("trends.next")

            Spacer()
        }
    }

    private var tiles: some View {
        LazyVGrid(
            columns: [
                GridItem(.flexible(), spacing: DesignTokens.Spacing.medium),
                GridItem(.flexible(), spacing: DesignTokens.Spacing.medium),
            ],
            spacing: DesignTokens.Spacing.medium
        ) {
            ForEach(TrendMetric.allCases) { item in
                TrendMetricTile(
                    metric: item,
                    count: item.count(in: periodEvents),
                    isSelected: item == metric
                ) {
                    metric = item
                }
            }
        }
    }

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            HStack {
                Text(metricTitle(metric))
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(metric.tint)
                Spacer()
                Text("trends.days \(recordedDays)")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }

            if buckets.contains(where: { $0.value != nil }) {
                Chart(buckets) { bucket in
                    BarMark(
                        x: .value("when", bucketLabel(bucket)),
                        y: .value("count", bucket.value ?? 0)
                    )
                    .foregroundStyle(metric.tint)
                    .cornerRadius(4)
                    .opacity(bucket.value == nil ? 0 : 1)
                    .accessibilityLabel(accessibilityLabel(bucket))
                }
                .chartXAxis {
                    AxisMarks(values: .automatic(desiredCount: 3)) { _ in
                        AxisValueLabel()
                            .foregroundStyle(DesignTokens.Color.textSecondary)
                    }
                }
                .chartYAxis(.hidden)
                .frame(height: 150)
                .accessibilityIdentifier("trends.chart")
            } else {
                Text("trends.noRecords")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 150)
            }
        }
        .padding(DesignTokens.Spacing.regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
    }

    private var ringCard: some View {
        TrendBristolRing(events: periodEvents)
            .padding(DesignTokens.Spacing.regular)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
    }

    private var recordedDays: Int {
        Set(periodEvents.map { Calendar.current.startOfDay(for: $0.happenedAt) }).count
    }

    private var periodText: String {
        let last = Calendar.current.date(byAdding: .day, value: -1, to: period.end) ?? period.end
        return "\(period.start.formatted(.dateTime.month().day())) – \(last.formatted(.dateTime.month().day()))"
    }

    private var canStepForward: Bool {
        TrendAggregation.period(for: range, containing: Date.now).end > period.end
    }

    private func bucketLabel(_ bucket: TrendBucket) -> String {
        range == .year
            ? bucket.start.formatted(.dateTime.month(.abbreviated))
            : bucket.start.formatted(.dateTime.month(.defaultDigits).day())
    }

    private func step(_ direction: Int) {
        let component: Calendar.Component = range.isDaily ? .day : (range == .sixMonths ? .month : .year)
        let value = range.isDaily ? 7 * direction : (range == .sixMonths ? 6 * direction : direction)
        anchor = Calendar.current.date(byAdding: component, value: value, to: anchor) ?? anchor
    }

    private func load() async {
        events = await model.allEvents()
    }

    private func accessibilityLabel(_ bucket: TrendBucket) -> String {
        let date = bucket.start.formatted(.dateTime.month().day())
        guard let value = bucket.value else {
            return date + "，" + String(localized: "trends.axis.none")
        }
        return date + "，" + String(localized: "trends.axis.value \(value)")
    }

    private func rangeTitle(_ item: TrendRange) -> LocalizedStringKey {
        switch item {
        case .week: "trends.range.week"
        case .month: "trends.range.month"
        case .sixMonths: "trends.range.sixMonths"
        case .year: "trends.range.year"
        }
    }

    private func metricTitle(_ item: TrendMetric) -> LocalizedStringKey {
        switch item {
        case .bowelMovements: "trends.metric.bowelMovements"
        case .meals: "trends.metric.meals"
        case .supplements: "trends.metric.supplements"
        case .medications: "trends.metric.medications"
        }
    }
}

/// What sits behind one bar: the records of those days, as facts.
struct BucketDetailView: View {
    let bucket: TrendBucket
    let events: [RecordedEvent]

    private var inside: [RecordedEvent] {
        events.filter { !$0.isDeleted && $0.happenedAt >= bucket.start && $0.happenedAt < bucket.end }
    }

    var body: some View {
        VStack(spacing: 0) {
            SheetHeader(titleKey: "trends.detail.title")
            List {
                if inside.isEmpty {
                    Text("trends.noRecords")
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                } else {
                    ForEach(inside) { event in
                        TimelineRow(event: event, isLast: false)
                    }
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
        }
        .background(DesignTokens.Color.background)
        .presentationDetents([.medium, .large])
    }
}
