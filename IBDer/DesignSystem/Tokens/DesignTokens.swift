import SwiftUI

/// Every visual constant in the app comes from here. Hard-coding a colour, radius,
/// spacing or font size in a screen is a review failure
/// (docs/design/design-tokens.md, docs/engineering/naming.md).
public enum DesignTokens {
    // MARK: - Colour

    public enum Color {
        // Brand palette — the logo and banner actually in use (ADR-0010).
        public static let ink = hex(0x1B133A)
        public static let plum = hex(0x852E83)
        public static let magenta = hex(0xD450B1)
        public static let rose = hex(0xF4779C)
        public static let amber = hex(0xFBB761)
        public static let cocoa = hex(0x302B50)
        public static let sand = hex(0xEED1B4)
        public static let dustyRose = hex(0xDE858A)

        // Semantic
        public static let background = hex(0xF6F5F7)
        public static let surface = hex(0xFFFFFF)
        public static let textPrimary = hex(0x1B133A)
        public static let textSecondary = hex(0x6B6880)
        public static let accent = hex(0x852E83)
        public static let accentSoft = hex(0xF3E7F2)
        public static let border = hex(0xE6E4EA)

        /// The brand gradient is for the logo/mark only — never UI chrome, never data
        /// (ADR-0012).
        public static let brandGradient = LinearGradient(
            colors: [ink, plum, magenta, rose, amber],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        private static func hex(_ value: UInt32) -> SwiftUI.Color {
            SwiftUI.Color(
                red: Double((value >> 16) & 0xFF) / 255,
                green: Double((value >> 8) & 0xFF) / 255,
                blue: Double(value & 0xFF) / 255
            )
        }
    }

    // MARK: - Spacing

    public enum Spacing {
        public static let xSmall: CGFloat = 4
        public static let small: CGFloat = 8
        public static let medium: CGFloat = 12
        public static let regular: CGFloat = 16
        public static let large: CGFloat = 24
        public static let xLarge: CGFloat = 32
    }

    // MARK: - Radius

    public enum Radius {
        public static let control: CGFloat = 12
        public static let card: CGFloat = 16
        public static let large: CGFloat = 20
    }

    // MARK: - Typography

    /// Semantic fonts only, so Dynamic Type keeps working. Never a fixed point size.
    public enum Typography {
        public static let display = Font.largeTitle.weight(.bold)
        public static let title = Font.title2.weight(.bold)
        public static let headline = Font.headline.weight(.semibold)
        public static let body = Font.body
        public static let caption = Font.footnote
    }

    // MARK: - Layout

    public enum Layout {
        public static let minimumTouchTarget: CGFloat = 44
        public static let cardBorderWidth: CGFloat = 1
    }
}
