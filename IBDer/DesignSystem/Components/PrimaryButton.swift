import SwiftUI

/// The one primary action on a sheet.
struct PrimaryButton: View {
    let titleKey: LocalizedStringKey
    var isEnabled = true
    var identifier = "common.save"
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(titleKey)
                .font(DesignTokens.Typography.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    DesignTokens.Color.accent.opacity(isEnabled ? 1 : 0.3),
                    in: RoundedRectangle(cornerRadius: DesignTokens.Radius.control)
                )
        }
        .buttonStyle(.plain)
        .accessibilityIdentifier(identifier)
        .disabled(!isEnabled)
    }
}
