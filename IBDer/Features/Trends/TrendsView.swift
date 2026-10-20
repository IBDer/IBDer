import SwiftUI

/// Where the record turns into a chart. The chart itself is the trends slice; until then this
/// says plainly that there is nothing to show yet.
struct TrendsView: View {
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.small) {
            Text("trends.empty.title")
                .font(DesignTokens.Typography.headline)
                .foregroundStyle(DesignTokens.Color.textPrimary)
            Text("trends.empty.body")
                .font(DesignTokens.Typography.body)
                .foregroundStyle(DesignTokens.Color.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(DesignTokens.Spacing.large)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(DesignTokens.Color.background)
    }
}
