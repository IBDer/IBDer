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

        // Semantic. These follow the system appearance: the brand palette is the light set, and a
        // dark set keeps the same relationships instead of leaving system controls unreadable.
        public static let background = dynamic(light: 0xF6F5F7, dark: 0x121016)
        public static let surface = dynamic(light: 0xFFFFFF, dark: 0x1D1A24)
        public static let textPrimary = dynamic(light: 0x1B133A, dark: 0xF3F0F7)
        public static let textSecondary = dynamic(light: 0x6B6880, dark: 0xABA6BC)
        public static let accent = dynamic(light: 0x852E83, dark: 0xC77BC4)
        public static let accentSoft = dynamic(light: 0xF3E7F2, dark: 0x3A2440)
        public static let border = dynamic(light: 0xE6E4EA, dark: 0x2F2B3A)

        /// The brand gradient is for the logo/mark only — never UI chrome, never data
        /// (ADR-0012).
        public static let brandGradient = LinearGradient(
            colors: [ink, plum, magenta, rose, amber],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        private static func dynamic(light: UInt32, dark: UInt32) -> SwiftUI.Color {
            SwiftUI.Color(uiColor: UIColor { traits in
                rgba(traits.userInterfaceStyle == .dark ? dark : light)
            })
        }

        private static func rgba(_ value: UInt32) -> UIColor {
            UIColor(
                red: CGFloat((value >> 16) & 0xFF) / 255,
                green: CGFloat((value >> 8) & 0xFF) / 255,
                blue: CGFloat(value & 0xFF) / 255,
                alpha: 1
            )
        }

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
