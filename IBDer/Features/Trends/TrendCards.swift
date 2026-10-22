import Charts
import SwiftUI

/// The identity colour of a metric. It tells the series apart; it never means good or bad.
extension TrendMetric {
    var tint: Color {
        switch self {
        case .bowelMovements: DesignTokens.Color.series[1]
        case .meals: DesignTokens.Color.series[5]
        case .supplements: DesignTokens.Color.series[3]
        case .medications: DesignTokens.Color.series[0]
        }
    }
}

/// One metric as a square: a coloured dot, the name, the number and its unit.
struct TrendMetricTile: View {
    let metric: TrendMetric
    let count: Int
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
                HStack(spacing: DesignTokens.Spacing.xSmall) {
                    Circle()
                        .fill(metric.tint)
                        .frame(width: 8, height: 8)
                    Text(title)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                        .lineLimit(1)
                }
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(verbatim: "\(count)")
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .foregroundStyle(DesignTokens.Color.textPrimary)
                    Text("trends.unit.times")
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DesignTokens.Spacing.medium)
            .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                    .stroke(isSelected ? DesignTokens.Color.accent : .clear, lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier("trends.tile.\(metric.rawValue)")
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

/// The stool forms as a ring: one slice per form, sized by how often it was recorded.
struct TrendBristolRing: View {
    let events: [RecordedEvent]

    private var entries: [(type: Int, count: Int)] {
        let stools = events.compactMap(\.payload.toiletEvent).filter { $0.outcome == .stool }
        return BristolType.allCases.compactMap { type in
            let times = stools.count { $0.bristol == type }
            return times > 0 ? (type.rawValue, times) : nil
        }
    }

    var body: some View {
        let entries = entries
        if entries.isEmpty {
            Text("trends.bristol.empty")
                .font(DesignTokens.Typography.caption)
                .foregroundStyle(DesignTokens.Color.textSecondary)
        } else {
            HStack(spacing: DesignTokens.Spacing.large) {
                Chart(entries, id: \.type) { entry in
                    SectorMark(
                        angle: .value("count", entry.count),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(DesignTokens.Color.series[(entry.type - 1) % DesignTokens.Color.series.count])
                    .cornerRadius(2)
                    .accessibilityLabel(Text("trends.bristol.legend \(entry.type) \(entry.count)"))
                }
                .chartLegend(.hidden)
                .frame(width: 120, height: 120)
                .clipped()

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
                    ForEach(entries, id: \.type) { entry in
                        HStack(spacing: DesignTokens.Spacing.xSmall) {
                            Circle()
                                .fill(DesignTokens.Color.series[(entry.type - 1) % DesignTokens.Color.series.count])
                                .frame(width: 8, height: 8)
                            Text("trends.bristol.legend \(entry.type) \(entry.count)")
                                .font(DesignTokens.Typography.caption)
                                .foregroundStyle(DesignTokens.Color.textSecondary)
                        }
                    }
                }
                Spacer(minLength: 0)
            }
        }
    }
}
