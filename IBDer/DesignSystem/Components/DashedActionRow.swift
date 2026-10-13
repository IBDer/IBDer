import SwiftUI

/// An unfinished-looking row: dashed border, title, hint, chevron. It reads as
/// "something is waiting for you" rather than as a button (see the reference teardown).
struct DashedActionRow: View {
    let titleKey: LocalizedStringKey
    let hintKey: LocalizedStringKey
    var symbol: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.medium) {
                if let symbol {
                    Image(systemName: symbol)
                        .font(.title3)
                        .foregroundStyle(DesignTokens.Color.accent)
                        .frame(width: 28)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(titleKey)
                        .font(DesignTokens.Typography.headline)
                        .foregroundStyle(DesignTokens.Color.textPrimary)
                    Text(hintKey)
                        .font(DesignTokens.Typography.caption)
                        .foregroundStyle(DesignTokens.Color.textSecondary)
                }
                Spacer(minLength: DesignTokens.Spacing.small)
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DesignTokens.Color.textSecondary)
            }
            .padding(DesignTokens.Spacing.regular)
            .frame(minHeight: DesignTokens.Layout.minimumTouchTarget + 16)
            .background(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                    .strokeBorder(
                        DesignTokens.Color.accent.opacity(0.5),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    DashedActionRow(titleKey: "confirm.title", hintKey: "confirm.subtitle", symbol: "checklist") {}
        .padding(DesignTokens.Spacing.regular)
        .background(DesignTokens.Color.background)
}
