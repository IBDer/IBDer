import SwiftUI

/// A minimal drawing of the Bristol form, ours rather than anyone else's artwork (ADR-0007).
/// It shows density and shape, not a literal photograph.
struct BristolGlyph: View {
    let type: BristolType
    var tint: Color = DesignTokens.Color.accent

    var body: some View {
        Canvas { context, size in
            let width = size.width
            let height = size.height
            let stroke = StrokeStyle(lineWidth: 1.5, lineCap: .round)

            switch type {
            case .type1:
                for centre in [(0.3, 0.3), (0.66, 0.26), (0.34, 0.7), (0.7, 0.72)] {
                    let radius = min(width, height) * 0.11
                    let rect = CGRect(
                        x: centre.0 * width - radius,
                        y: centre.1 * height - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(tint))
                }
            case .type2:
                let radius = min(width, height) * 0.17
                for centre in [(0.3, 0.5), (0.5, 0.44), (0.7, 0.52)] {
                    let rect = CGRect(
                        x: centre.0 * width - radius,
                        y: centre.1 * height - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(tint))
                }
            case .type3:
                let rect = CGRect(x: width * 0.16, y: height * 0.3, width: width * 0.68, height: height * 0.4)
                context.fill(Path(roundedRect: rect, cornerRadius: height * 0.2), with: .color(tint))
                for x in [0.36, 0.5, 0.62] {
                    var crack = Path()
                    crack.move(to: CGPoint(x: width * x, y: height * 0.36))
                    crack.addLine(to: CGPoint(x: width * x, y: height * 0.64))
                    context.stroke(crack, with: .color(DesignTokens.Color.surface), style: stroke)
                }
            case .type4:
                let rect = CGRect(x: width * 0.14, y: height * 0.34, width: width * 0.72, height: height * 0.32)
                context.fill(Path(roundedRect: rect, cornerRadius: height * 0.16), with: .color(tint))
            case .type5:
                let rect = CGRect(x: width * 0.18, y: height * 0.38, width: width * 0.64, height: height * 0.26)
                context.fill(Path(roundedRect: rect, cornerRadius: height * 0.13), with: .color(tint))
                for centre in [(0.2, 0.44), (0.82, 0.5)] {
                    let radius = min(width, height) * 0.1
                    let dot = CGRect(
                        x: centre.0 * width - radius,
                        y: centre.1 * height - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                    context.fill(Path(ellipseIn: dot), with: .color(tint))
                }
            case .type6:
                for centre in [(0.28, 0.4), (0.52, 0.36), (0.72, 0.46), (0.4, 0.66), (0.65, 0.68)] {
                    let radius = min(width, height) * 0.13
                    let rect = CGRect(
                        x: centre.0 * width - radius,
                        y: centre.1 * height - radius,
                        width: radius * 2,
                        height: radius * 2
                    )
                    context.fill(Path(ellipseIn: rect), with: .color(tint.opacity(0.75)))
                }
            case .type7:
                for y in [0.34, 0.5, 0.66] {
                    var line = Path()
                    line.move(to: CGPoint(x: width * 0.14, y: height * y))
                    line.addQuadCurve(
                        to: CGPoint(x: width * 0.86, y: height * y),
                        control: CGPoint(x: width * 0.5, y: height * (y - 0.08))
                    )
                    context.stroke(line, with: .color(tint), style: stroke)
                }
            }
        }
    }
}
