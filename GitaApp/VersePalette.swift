import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Bokeh Blob

struct BokehBlob {
    let x: CGFloat
    let y: CGFloat
    let diameter: CGFloat
    let blurRadius: CGFloat
    let color: Color
    let opacity: Double
}

// MARK: - Verse Palette (Chapter-based, 2 entries)

struct VersePalette: Identifiable {
    let id: Int
    let baseColor: Color
    let blobs: [BokehBlob]
    let grainOpacity: Double

    var onPaletteText: Color { .primary }
}

extension VersePalette {

    static let all: [VersePalette] = [

        // ── Chapter 1 — Warm Ivory ───────────────────────────────────────────
        // Almost white base with very subtle, warm pearl/peach blooms.
        // Extremely mild and elegant.
        VersePalette(
            id: 0,
            baseColor: Color(red: 0.98, green: 0.97, blue: 0.96),
            blobs: [
                BokehBlob(x: 0.20, y: 0.20, diameter: 500,
                          blurRadius: 120,
                          color: Color(red: 0.96, green: 0.90, blue: 0.85),
                          opacity: 0.6),
                BokehBlob(x: 0.80, y: 0.70, diameter: 600,
                          blurRadius: 150,
                          color: Color(red: 0.98, green: 0.93, blue: 0.88),
                          opacity: 0.5),
            ],
            grainOpacity: 0.08 // very light grain
        ),

        // ── Chapter 2 — Morning Mist ─────────────────────────────────────────
        // Almost white base with very subtle, cool sage/blue mist.
        VersePalette(
            id: 1,
            baseColor: Color(red: 0.97, green: 0.98, blue: 0.98),
            blobs: [
                BokehBlob(x: 0.50, y: 0.10, diameter: 550,
                          blurRadius: 130,
                          color: Color(red: 0.88, green: 0.92, blue: 0.94),
                          opacity: 0.5),
                BokehBlob(x: 0.30, y: 0.80, diameter: 500,
                          blurRadius: 140,
                          color: Color(red: 0.90, green: 0.94, blue: 0.92),
                          opacity: 0.4),
            ],
            grainOpacity: 0.08
        ),
    ]
}

// MARK: - Grain Texture (CoreImage, GPU-accelerated, cached)

final class GrainTextureCache {
    static let shared = GrainTextureCache()
    private var cache: [String: UIImage] = [:]
    private let context = CIContext(options: [.useSoftwareRenderer: false])

    func texture(for size: CGSize) -> UIImage? {
        let key = "\(Int(size.width))x\(Int(size.height))"
        if let hit = cache[key] { return hit }
        let img = makeTexture(size: size)
        cache[key] = img
        return img
    }

    private func makeTexture(size: CGSize) -> UIImage? {
        guard
            let randomFilter = CIFilter(name: "CIRandomGenerator"),
            let randomOutput = randomFilter.outputImage
        else { return nil }

        let cropped = randomOutput.cropped(to: CGRect(origin: .zero, size: size))

        guard
            let colorCtrl = CIFilter(name: "CIColorControls",
                parameters: ["inputImage": cropped,
                             "inputSaturation": 0.0,
                             "inputBrightness": 0.0,
                             "inputContrast": 1.1]),
            let grey = colorCtrl.outputImage,
            let cgImg = context.createCGImage(grey, from: grey.extent)
        else { return nil }

        return UIImage(cgImage: cgImg)
    }
}

// MARK: - Grain Overlay

struct GrainOverlay: View {
    let opacity: Double
    @State private var grainImage: UIImage?

    var body: some View {
        GeometryReader { _ in
            if let img = grainImage {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .blendMode(.multiply) // Multiply works better for dark grain on light background
                    .opacity(opacity)
                    .allowsHitTesting(false)
            }
        }
        .ignoresSafeArea()
        .task {
            let size = UIScreen.main.bounds.size
            grainImage = await Task.detached(priority: .utility) {
                GrainTextureCache.shared.texture(for: size)
            }.value
        }
    }
}

// MARK: - Full-Screen Bokeh Background

struct VerseBackgroundView: View {
    let palette: VersePalette

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Base
                palette.baseColor

                // Blobs
                ForEach(palette.blobs.indices, id: \.self) { i in
                    let blob = palette.blobs[i]
                    Circle()
                        .fill(blob.color)
                        .frame(width: blob.diameter, height: blob.diameter)
                        .position(
                            x: blob.x * geo.size.width,
                            y: blob.y * geo.size.height
                        )
                        .blur(radius: blob.blurRadius)
                        .opacity(blob.opacity)
                }

                // Film-grain texture on top
                GrainOverlay(opacity: palette.grainOpacity)
            }
        }
        .ignoresSafeArea()
    }
}
