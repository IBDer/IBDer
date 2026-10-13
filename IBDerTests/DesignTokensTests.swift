import Testing
import SwiftUI
@testable import IBDer

/// Task 1.2 verification: every token equals the value documented in
/// docs/design/design-tokens.md. If a token drifts, this test is the alarm.
struct DesignTokensTests {

    @Test func spacingScaleMatchesDocumentation() {
        #expect(DesignTokens.Spacing.xSmall == 4)
        #expect(DesignTokens.Spacing.small == 8)
        #expect(DesignTokens.Spacing.medium == 12)
        #expect(DesignTokens.Spacing.regular == 16)
        #expect(DesignTokens.Spacing.large == 24)
        #expect(DesignTokens.Spacing.xLarge == 32)
    }

    @Test func radiusScaleMatchesDocumentation() {
        #expect(DesignTokens.Radius.control == 12)
        #expect(DesignTokens.Radius.card == 16)
        #expect(DesignTokens.Radius.large == 20)
    }

    @Test func minimumTouchTargetMeetsAccessibilityFloor() {
        #expect(DesignTokens.Layout.minimumTouchTarget >= 44)
    }

    @Test func brandColoursMatchTheDeployedLogo() {
        // ADR-0010: the palette comes from the logo/banner actually in use.
        let expected: [(Color, UInt32)] = [
            (DesignTokens.Color.ink, 0x1B133A),
            (DesignTokens.Color.plum, 0x852E83),
            (DesignTokens.Color.magenta, 0xD450B1),
            (DesignTokens.Color.rose, 0xF4779C),
            (DesignTokens.Color.amber, 0xFBB761),
        ]
        for (colour, hex) in expected {
            #expect(DesignTokens.Color.rgb(of: colour) == hex)
        }
    }
}

extension DesignTokens.Color {
    /// Test-only accessor so the hex literals above stay the single source of truth.
    static func rgb(of colour: Color) -> UInt32? {
        let ui = UIColor(colour)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return UInt32((r * 255).rounded()) << 16
            | UInt32((g * 255).rounded()) << 8
            | UInt32((b * 255).rounded())
    }
}
