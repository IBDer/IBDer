import SwiftUI

/// The small heading above a group of choices.
struct SectionTitle: View {
    let titleKey: LocalizedStringKey

    var body: some View {
        Text(titleKey)
            .font(DesignTokens.Typography.caption)
            .foregroundStyle(DesignTokens.Color.textSecondary)
    }
}
