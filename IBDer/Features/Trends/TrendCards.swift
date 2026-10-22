import Charts
import SwiftUI

/// The card every trends block sits in.
struct TrendCard<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.small) {
            content
        }
        .padding(DesignTokens.Spacing.regular)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
    }
}

/// The four metrics at a glance: a small strip per metric plus the days it was recorded.
struct TrendOverviewCard: View {
    let events: [RecordedEvent]
    let range: TrendRange
    let anchor: Date
    let selected: TrendMetric

    var body: some View {
        TrendCard {
            Text("trends.overview")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
            ForEach(TrendMetric.allCases) { item in
                row(item)
            }
        }
    }

    private func row(_ item: TrendMetric) -> some View {
        let buckets = TrendAggregation.buckets(for: range, containing: anchor, events: events, metric: item)
        let days = TrendOverviewCard.daysWith(item, in: events, range: range, anchor: anchor)
        return HStack(spacing: DesignTokens.Spacing.small) {
            Text(title(item))
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textPrimary)
                .frame(width: 64, alignment: .leading)
            Chart(buckets) { bucket in
                BarMark(
                    x: .value("when", bucket.start),
                    y: .value("count", bucket.value ?? 0)
                )
                .foregroundStyle(DesignTokens.Color.accent.opacity(item == selected ? 1 : 0.5))
                .opacity(bucket.value == nil ? 0 : 1)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(width: 120, height: 26)
            Text("trends.recordedDays \(days)")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
                .frame(width: 74, alignment: .trailing)
        }
    }

    private func title(_ item: TrendMetric) -> LocalizedStringKey {
        switch item {
        case .bowelMovements: "trends.metric.bowelMovements"
        case .meals: "trends.metric.meals"
        case .supplements: "trends.metric.supplements"
        case .medications: "trends.metric.medications"
        }
    }

    static func daysWith(_ item: TrendMetric, in events: [RecordedEvent], range: TrendRange, anchor: Date) -> Int {
        let period = TrendAggregation.period(for: range, containing: anchor)
        let inPeriod = events.filter { !$0.isDeleted && $0.happenedAt >= period.start && $0.happenedAt < period.end }
        let days = inPeriod.filter { event in
            switch item {
            case .bowelMovements:
                return event.payload.toiletEvent?.isBowelMovement == true
            case .meals:
                if case let .meal(meal) = event.payload {
                    return meal.kind == .meal
                }
                return false
            case .supplements:
                if case let .meal(meal) = event.payload {
                    return meal.kind == .supplement
                }
                return false
            case .medications:
                if case .medication = event.payload {
                    return true
                }
                return false
            }
        }
        return Set(days.map { Calendar.current.startOfDay(for: $0.happenedAt) }).count
    }
}

/// Bristol form distribution: how often each form was recorded in the period.
struct TrendBristolCard: View {
    let events: [RecordedEvent]

    private var counts: [(type: Int, count: Int)] {
        let stools = events.compactMap(\.payload.toiletEvent).filter { $0.outcome == .stool }
        return BristolType.allCases.map { type in
            (type.rawValue, stools.count { $0.bristol == type })
        }
    }

    var body: some View {
        let entries = counts
        let maximum = entries.map(\.count).max() ?? 0
        return TrendCard {
            Text("trends.bristol.title")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
            if maximum == 0 {
                Text("trends.bristol.empty")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            } else {
                ForEach(entries, id: \.type) { entry in
                    HStack(spacing: DesignTokens.Spacing.small) {
                        Text("trends.bristol.type \(entry.type)")
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Color.textPrimary)
                            .frame(width: 48, alignment: .leading)
                        GeometryReader { geometry in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(DesignTokens.Color.accent.opacity(0.85))
                                .frame(width: geometry.size.width * CGFloat(entry.count) / CGFloat(maximum))
                        }
                        .frame(height: 10)
                        Text(verbatim: "\(entry.count)")
                            .font(DesignTokens.Typography.caption)
                            .foregroundStyle(DesignTokens.Color.textSecondary)
                            .frame(width: 24, alignment: .trailing)
                    }
                }
            }
        }
    }
}

/// What the biologic plan produced in this period.
struct TrendBiologicCard: View {
    let records: [InfusionRecord]
    let period: (start: Date, end: Date)

    var body: some View {
        let doses = records.filter { $0.date >= period.start && $0.date < period.end }
        TrendCard {
            Text("trends.biologic.title")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
            Text("trends.biologic.doses \(doses.count)")
                .font(DesignTokens.Typography.body)
                .foregroundStyle(DesignTokens.Color.textPrimary)
            if let last = doses.map(\.date).max() {
                Text("trends.biologic.last \(last.formatted(.dateTime.month().day()))")
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
        }
    }
}
