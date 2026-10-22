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

/// One metric as a tile: the number first, the name second, a strip of the period underneath.
struct TrendMetricTile: View {
    let metric: TrendMetric
    let buckets: [TrendBucket]
    let count: Int
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
            Text(verbatim: "\(count)")
                .font(.title2.weight(.semibold))
                .foregroundStyle(DesignTokens.Color.textPrimary)
            Text(title)
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
            Chart(buckets) { bucket in
                BarMark(
                    x: .value("when", bucket.start),
                    y: .value("count", bucket.value ?? 0)
                )
                .foregroundStyle(DesignTokens.Color.accent.opacity(isSelected ? 1 : 0.45))
                .cornerRadius(1.5)
                .opacity(bucket.value == nil ? 0 : 1)
            }
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
            .frame(height: 22)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var title: LocalizedStringKey {
        switch metric {
        case .bowelMovements: "trends.metric.bowelMovements"
        case .meals: "trends.metric.meals"
        case .supplements: "trends.metric.supplements"
        case .medications: "trends.metric.medications"
        }
    }
}

/// The Bristol forms as one stacked strip, with a compact legend. No "most common": that is a
/// conclusion, and this screen only shows counts.
struct TrendBristolStrip: View {
    let events: [RecordedEvent]

    /// Only the forms that actually occurred; a zero row is noise, not information.
    private var entries: [(type: Int, count: Int)] {
        let stools = events.compactMap(\.payload.toiletEvent).filter { $0.outcome == .stool }
        return BristolType.allCases.compactMap { type in
            let times = stools.count { $0.bristol == type }
            return times > 0 ? (type.rawValue, times) : nil
        }
    }

    var body: some View {
        let entries = entries
        let total = entries.reduce(0) { partial, entry in partial + entry.count }
        TrendCard {
            if total == 0 {
                Text("trends.bristol.empty")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            } else {
                GeometryReader { geometry in
                    HStack(spacing: 2) {
                        ForEach(entries, id: \.type) { entry in
                            RoundedRectangle(cornerRadius: 3)
                                .fill(DesignTokens.Color.accent.opacity(opacity(entry.type)))
                                .frame(width: max(3, geometry.size.width * CGFloat(entry.count) / CGFloat(total)))
                        }
                    }
                }
                .frame(height: 18)

                LazyVGrid(columns: [GridItem(.adaptive(minimum: 56), spacing: 8)], alignment: .leading, spacing: 4) {
                    ForEach(entries, id: \.type) { entry in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(DesignTokens.Color.accent.opacity(opacity(entry.type)))
                                .frame(width: 7, height: 7)
                            Text("trends.bristol.legend \(entry.type) \(entry.count)")
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(DesignTokens.Color.textSecondary)
                        }
                    }
                }
            }
        }
    }

    /// One hue, seven steps: the order is the Bristol scale, not a judgement.
    private func opacity(_ type: Int) -> Double {
        0.35 + 0.65 * (1 - Double(type - 1) / 6)
    }
}
