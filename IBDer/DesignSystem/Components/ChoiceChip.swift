import SwiftUI

/// One selectable option. Used for the short lists a recording sheet asks for.
struct ChoiceChip: View {
    let titleKey: LocalizedStringKey
    let isSelected: Bool
    /// Stable, language-independent identity for tests and VoiceOver (naming.md: screen.element).
    var identifier: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(titleKey)
                .font(DesignTokens.Typography.body)
                .foregroundStyle(isSelected ? DesignTokens.Color.accent : DesignTokens.Color.textPrimary)
                .frame(maxWidth: .infinity)
                .frame(minHeight: DesignTokens.Layout.minimumTouchTarget)
                .padding(.horizontal, DesignTokens.Spacing.small)
                .background(
                    isSelected ? DesignTokens.Color.accentSoft : DesignTokens.Color.surface,
                    in: RoundedRectangle(cornerRadius: DesignTokens.Radius.control)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.control)
                        .stroke(isSelected ? DesignTokens.Color.accent : DesignTokens.Color.border, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier ?? "")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}
