import Charts
import SwiftUI

/// The trends tab: a factual bar chart over four calendar periods, with the days that have no
/// record kept visible instead of drawn as zero.
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

    private var unrecorded: Int {
        TrendAggregation.unrecordedDays(in: buckets)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: DesignTokens.Spacing.large) {
                rangePicker
                periodHeader
                metricPicker
                chart
                coverage
                recordedList
                Spacer(minLength: 0)
            }
            .padding(.horizontal, DesignTokens.Spacing.regular)
            .padding(.top, DesignTokens.Spacing.small)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(DesignTokens.Color.background)
            .navigationTitle("tab.trends")
            .navigationBarTitleDisplayMode(.large)
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

    private var metricPicker: some View {
        Menu {
            ForEach(TrendMetric.allCases) { item in
                Button {
                    metric = item
                } label: {
                    Text(metricTitle(item))
                }
            }
        } label: {
            HStack(spacing: DesignTokens.Spacing.xSmall) {
                Text(metricTitle(metric))
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Color.accent)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(DesignTokens.Color.accent)
            }
            .padding(.horizontal, DesignTokens.Spacing.medium)
            .frame(height: DesignTokens.Layout.minimumTouchTarget)
            .background(DesignTokens.Color.accentSoft, in: Capsule())
        }
        .accessibilityIdentifier("trends.metric")
    }

    @ViewBuilder private var chart: some View {
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
                AxisMarks(values: .automatic(desiredCount: 4)) { _ in
                    AxisValueLabel()
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                }
            }
            .frame(height: 220)
            .accessibilityIdentifier("trends.chart")
        } else {
            Text("trends.noRecords")
                .font(DesignTokens.Typography.body)
                .foregroundStyle(DesignTokens.Color.textSecondary)
                .frame(maxWidth: .infinity)
                .frame(height: 220)
        }
    }

    private var coverage: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
            if unrecorded > 0 {
                Text("trends.coverage \(unrecorded)")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
                    .accessibilityIdentifier("trends.coverage")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// Every bucket that carries a record, as a row: the inspectable version of the chart, and the
    /// one VoiceOver can read.
    private var recordedList: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(buckets.filter { $0.value != nil }) { bucket in
                Button {
                    selected = bucket
                } label: {
                    HStack {
                        Text(bucketLabel(bucket))
                            .font(DesignTokens.Typography.body)
                            .foregroundStyle(DesignTokens.Color.textPrimary)
                        Spacer()
                        Text(verbatim: "\(bucket.value ?? 0)")
                            .font(DesignTokens.Typography.headline)
                            .foregroundStyle(DesignTokens.Color.textPrimary)
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(DesignTokens.Color.textSecondary)
                    }
                    .frame(minHeight: DesignTokens.Layout.minimumTouchTarget)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("trends.bucket.\(bucketLabel(bucket))")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var periodText: String {
        let period = TrendAggregation.period(for: range, containing: anchor)
        let last = Calendar.current.date(byAdding: .day, value: -1, to: period.end) ?? period.end
        return "\(period.start.formatted(.dateTime.month().day())) – \(last.formatted(.dateTime.month().day()))"
    }

    private var canStepForward: Bool {
        TrendAggregation.period(for: range, containing: Date.now).end
            > TrendAggregation.period(for: range, containing: anchor).end
    }

    /// A category label per bucket. A continuous date axis gives a single day almost no width at a
    /// year scale, so the buckets are drawn as categories instead.
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
