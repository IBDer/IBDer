import SwiftUI

/// A labelled number entry with a unit: height, weight, and whatever needs one later.
struct NumberRow: View {
    let titleKey: LocalizedStringKey
    let identifier: String
    let placeholder: LocalizedStringKey
    let unit: LocalizedStringKey
    @Binding var text: String

    var body: some View {
        HStack {
            Text(titleKey)
                .font(DesignTokens.Typography.body)
                .foregroundStyle(DesignTokens.Color.textPrimary)
            Spacer(minLength: DesignTokens.Spacing.medium)
            TextField(placeholder, text: $text)
                .keyboardType(.decimalPad)
                .multilineTextAlignment(.trailing)
                .font(DesignTokens.Typography.body)
                .frame(width: 90)
                .accessibilityIdentifier("profile.field.\(identifier)")
            Text(unit)
                .font(DesignTokens.Typography.body)
                .foregroundStyle(DesignTokens.Color.textSecondary)
        }
        .padding(.horizontal, DesignTokens.Spacing.medium)
        .frame(minHeight: DesignTokens.Layout.minimumTouchTarget + 12)
        .background(DesignTokens.Color.surface, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.control))
    }
}
