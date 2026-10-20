import SwiftUI

/// One of the four peer recording entry points. Structure borrowed from the reference teardown;
/// the visual language is ours (ADR-0007, ADR-0012).
struct EntryChip: View {
    let symbol: String
    let titleKey: LocalizedStringKey
    /// Stable, language-independent identity for tests and VoiceOver (naming.md: screen.element).
    let identifier: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignTokens.Spacing.xSmall) {
                Image(systemName: symbol)
                    .font(.title3)
                    .foregroundStyle(DesignTokens.Color.accent)
                Text(titleKey)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
            }
            .padding(.vertical, DesignTokens.Spacing.small)
            .frame(maxWidth: .infinity)
            .frame(minHeight: DesignTokens.Layout.minimumTouchTarget + 20)
            .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        }
        // Three entries have to stay on one row: the label may grow, the layout may not.
        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        .buttonStyle(.plain)
        .accessibilityLabel(Text(titleKey))
        .accessibilityIdentifier(identifier)
    }
}

#Preview {
    HStack(spacing: DesignTokens.Spacing.small) {
        EntryChip(symbol: "drop.fill", titleKey: "entry.toilet", identifier: "entry.toilet") {}
        EntryChip(symbol: "fork.knife", titleKey: "entry.meal", identifier: "entry.meal") {}
        EntryChip(symbol: "pills.fill", titleKey: "entry.medication", identifier: "entry.medication") {}
        EntryChip(symbol: "syringe.fill", titleKey: "entry.infusion", identifier: "entry.infusion") {}
    }
    .padding(DesignTokens.Spacing.regular)
    .background(DesignTokens.Color.background)
}
