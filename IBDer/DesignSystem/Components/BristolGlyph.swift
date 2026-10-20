import SwiftUI

/// A drawing of the Bristol form, made here rather than borrowed (ADR-0007).
///
/// The seven types differ by silhouette: separate hard lumps, a lumpy log, a cracked log, a smooth
/// log, soft separate blobs, a ragged mass, and a puddle. Flat colour only — a gradient on data is
/// chrome this product does not use (ADR-0012).
struct BristolGlyph: View {
    let type: BristolType
    var tint: Color = DesignTokens.Color.accent

    var body: some View {
        Canvas { context, size in
            let sketch = Self.sketch(for: type, in: size)
            context.fill(sketch.path, with: .color(tint))
            if type == .type3 {
                Self.drawCracks(in: &context, size: size)
            }
        }
        .accessibilityHidden(true)
    }

    // MARK: - Shapes

    private static func sketch(for type: BristolType, in size: CGSize) -> Sketch {
        switch type {
        case .type1: hardLumps(size)
        case .type2: lumpyLog(size)
        case .type3: crackedLog(size)
        case .type4: smoothLog(size)
        case .type5: softBlobs(size)
        case .type6: raggedMass(size)
        case .type7: puddle(size)
        }
    }

    private static func hardLumps(_ size: CGSize) -> Sketch {
        var sketch = Sketch(size: size)
        sketch.circle(0.22, 0.32, 0.16)
        sketch.circle(0.52, 0.28, 0.14)
        sketch.circle(0.76, 0.44, 0.15)
        sketch.circle(0.36, 0.72, 0.15)
        sketch.circle(0.66, 0.74, 0.12)
        return sketch
    }

    private static func lumpyLog(_ size: CGSize) -> Sketch {
        var sketch = Sketch(size: size)
        sketch.circle(0.22, 0.52, 0.17)
        sketch.circle(0.38, 0.42, 0.16)
        sketch.circle(0.54, 0.52, 0.17)
        sketch.circle(0.7, 0.44, 0.16)
        sketch.circle(0.82, 0.54, 0.14)
        return sketch
    }

    private static func crackedLog(_ size: CGSize) -> Sketch {
        var sketch = Sketch(size: size)
        sketch.log(from: 0.14, to: 0.86, thickness: 0.4)
        sketch.circle(0.32, 0.36, 0.12)
        sketch.circle(0.56, 0.33, 0.1)
        sketch.circle(0.76, 0.39, 0.09)
        return sketch
    }

    private static func smoothLog(_ size: CGSize) -> Sketch {
        var sketch = Sketch(size: size)
        sketch.log(from: 0.12, to: 0.88, thickness: 0.42)
        return sketch
    }

    private static func softBlobs(_ size: CGSize) -> Sketch {
        var sketch = Sketch(size: size)
        sketch.blob(0.28, 0.5, 0.17, 0.16)
        sketch.blob(0.52, 0.44, 0.16, 0.15)
        sketch.blob(0.74, 0.54, 0.16, 0.14)
        sketch.blob(0.92, 0.66, 0.08, 0.07)
        return sketch
    }

    private static func raggedMass(_ size: CGSize) -> Sketch {
        var sketch = Sketch(size: size)
        sketch.blob(0.24, 0.54, 0.15, 0.13)
        sketch.blob(0.4, 0.46, 0.14, 0.12)
        sketch.blob(0.56, 0.52, 0.15, 0.13)
        sketch.blob(0.72, 0.46, 0.13, 0.11)
        sketch.blob(0.64, 0.64, 0.11, 0.08)
        sketch.blob(0.44, 0.66, 0.1, 0.08)
        return sketch
    }

    private static func puddle(_ size: CGSize) -> Sketch {
        var sketch = Sketch(size: size)
        sketch.blob(0.5, 0.52, 0.36, 0.16)
        sketch.blob(0.2, 0.64, 0.08, 0.06)
        sketch.blob(0.82, 0.4, 0.06, 0.05)
        return sketch
    }

    private static func drawCracks(in context: inout GraphicsContext, size: CGSize) {
        for x in [0.36, 0.5, 0.64] {
            var crack = Path()
            crack.move(to: CGPoint(x: size.width * x, y: size.height * 0.34))
            crack.addLine(to: CGPoint(x: size.width * x, y: size.height * 0.58))
            context.stroke(
                crack,
                with: .color(DesignTokens.Color.surface),
                style: StrokeStyle(lineWidth: 2, lineCap: .round)
            )
        }
    }

    /// Builds one silhouette from overlapping pieces. Coordinates are fractions of the canvas.
    private struct Sketch {
        let size: CGSize
        var path = Path()

        private var unit: CGFloat {
            min(size.width, size.height)
        }

        mutating func circle(_ x: CGFloat, _ y: CGFloat, _ radius: CGFloat) {
            let r = unit * radius
            path.addEllipse(in: CGRect(
                x: x * size.width - r,
                y: y * size.height - r,
                width: r * 2,
                height: r * 2
            ))
        }

        mutating func blob(_ x: CGFloat, _ y: CGFloat, _ radiusX: CGFloat, _ radiusY: CGFloat) {
            path.addEllipse(in: CGRect(
                x: x * size.width - unit * radiusX,
                y: y * size.height - unit * radiusY,
                width: unit * radiusX * 2,
                height: unit * radiusY * 2
            ))
        }

        mutating func log(from start: CGFloat, to end: CGFloat, thickness: CGFloat) {
            let rect = CGRect(
                x: start * size.width,
                y: 0.5 * size.height - unit * thickness / 2,
                width: (end - start) * size.width,
                height: unit * thickness
            )
            path.addRoundedRect(
                in: rect,
                cornerSize: CGSize(width: unit * thickness / 2, height: unit * thickness / 2)
            )
        }
    }
}
