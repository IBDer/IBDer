import Charts
import SwiftUI

/// Three blocks: the selected metric big, the four metrics as tiles, and the stool forms as one
/// strip. Counts only — no score, no average, no verdict.
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
                VStack(spacing: DesignTokens.Spacing.medium) {
                    rangePicker
                    periodHeader
                    mainCard
                    tilesCard
                    TrendBristolStrip(events: periodEvents)
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

    private var rangePicker: some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            ForEach(TrendRange.allCases) { item in
                ChoiceChip(
                    titleKey: rangeTitle(item),
                    isSelected: range == item,
                    identifier: "trends.range.\(item.rawValue)"
                ) {
                    range = item
                }
            }
        }
    }

    private var periodHeader: some View {
        HStack {
            arrow("chevron.left", identifier: "trends.previous") { step(-1) }
            Spacer()
            Text(periodText)
                .font(DesignTokens.Typography.headline)
                .foregroundStyle(DesignTokens.Color.textPrimary)
                .accessibilityIdentifier("trends.period")
            Spacer()
            arrow("chevron.right", identifier: "trends.next") { step(1) }
                .disabled(!canStepForward)
                .opacity(canStepForward ? 1 : 0.3)
        }
    }

    private var mainCard: some View {
        TrendCard {
            HStack(alignment: .firstTextBaseline) {
                Text(verbatim: "\(metricCount)")
                    .font(.system(size: 44, weight: .semibold, design: .rounded))
                    .foregroundStyle(DesignTokens.Color.textPrimary)
                menu
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
                    .foregroundStyle(DesignTokens.Color.accent)
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
                .frame(height: 170)
                .accessibilityIdentifier("trends.chart")
            } else {
                Text("trends.noRecords")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
                    .frame(maxWidth: .infinity, minHeight: 170)
            }
        }
    }

    private var menu: some View {
        Menu {
            ForEach(TrendMetric.allCases) { item in
                Button {
                    metric = item
                } label: {
                    Text(metricTitle(item))
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(metricTitle(metric))
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10))
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
        }
        .accessibilityIdentifier("trends.metric")
    }

    private var tilesCard: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: DesignTokens.Spacing.regular),
                            GridItem(.flexible())], spacing: DesignTokens.Spacing.regular) {
            ForEach(TrendMetric.allCases) { item in
                let buckets = TrendAggregation.buckets(for: range, containing: anchor, events: events, metric: item)
                TrendMetricTile(
                    metric: item,
                    buckets: buckets,
                    count: item.count(in: periodEvents),
                    isSelected: item == metric
                )
            }
        }
        .padding(DesignTokens.Spacing.regular)
        .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
    }

    private var metricCount: Int {
        metric.count(in: periodEvents)
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

    private func arrow(_ symbol: String, identifier: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.headline)
                .foregroundStyle(DesignTokens.Color.accent)
                .frame(width: DesignTokens.Layout.minimumTouchTarget, height: DesignTokens.Layout.minimumTouchTarget)
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
    }

    private func accessibilityLabel(_ bucket: TrendBucket) -> String {
        let date = bucket.start.formatted(.dateTime.month().day())
        guard let value = bucket.value else { return "\(date)，没有记录" }
        return "\(date)，\(value)"
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
