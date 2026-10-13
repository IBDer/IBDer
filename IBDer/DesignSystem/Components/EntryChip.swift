import SwiftUI

/// One of the four peer recording entry points. Structure borrowed from the reference teardown;
/// the visual language is ours (ADR-0007, ADR-0012).
struct EntryChip: View {
    let symbol: String
    let titleKey: LocalizedStringKey
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: DesignTokens.Spacing.small) {
                Image(systemName: symbol)
                    .font(.title3)
                    .foregroundStyle(DesignTokens.Color.accent)
                    .frame(height: 22)
                Text(titleKey)
                    .font(DesignTokens.Typography.caption)
                    .foregroundStyle(DesignTokens.Color.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .frame(minHeight: DesignTokens.Layout.minimumTouchTarget + 20)
            .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(titleKey))
    }
}

#Preview {
    HStack(spacing: DesignTokens.Spacing.small) {
        EntryChip(symbol: "drop.fill", titleKey: "entry.toilet") {}
        EntryChip(symbol: "fork.knife", titleKey: "entry.meal") {}
        EntryChip(symbol: "pills.fill", titleKey: "entry.medication") {}
        EntryChip(symbol: "syringe.fill", titleKey: "entry.infusion") {}
    }
    .padding(DesignTokens.Spacing.regular)
    .background(DesignTokens.Color.background)
}
