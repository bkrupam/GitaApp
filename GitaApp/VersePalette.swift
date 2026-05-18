import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Verse Palette

struct VersePalette: Identifiable {
    let id: Int
    let color1: Color     // first hue anchor — top-leading corner
    let color2: Color     // second hue anchor — bottom-trailing corner
    let grainOpacity: Double

    // Near-white used for the other corners and center of the mesh
    static let base = Color(red: 0.975, green: 0.975, blue: 0.978)
    var onPaletteText: Color { .primary }
}

// MARK: - Chapter Palettes
// Each chapter gets a warm + cool complementary pair that blend diagonally.
// Inspired by the soft, airy dual-hue gradient style (e.g. #FDF3F5 blush ↔ #B5D1E2 powder blue).

extension VersePalette {

    static let all: [VersePalette] = [

        // Ch 1  Arjuna Vishada — Blush + Powder Blue  (matches the reference exactly)
        VersePalette(id: 0,
            color1: Color(red: 0.99, green: 0.86, blue: 0.88),
            color2: Color(red: 0.71, green: 0.83, blue: 0.93),
            grainOpacity: 0.05),

        // Ch 2  Sankhya Yoga — Warm Ivory + Periwinkle
        VersePalette(id: 1,
            color1: Color(red: 0.98, green: 0.96, blue: 0.92),
            color2: Color(red: 0.75, green: 0.80, blue: 0.97),
            grainOpacity: 0.05),

        // Ch 3  Karma Yoga — Soft Peach + Sage
        VersePalette(id: 2,
            color1: Color(red: 1.00, green: 0.89, blue: 0.83),
            color2: Color(red: 0.77, green: 0.93, blue: 0.82),
            grainOpacity: 0.05),

        // Ch 4  Jnana Karma Sanyasa — Cream + Sky Blue  (matches the airy blue reference)
        VersePalette(id: 3,
            color1: Color(red: 0.97, green: 0.95, blue: 0.91),
            color2: Color(red: 0.69, green: 0.85, blue: 0.97),
            grainOpacity: 0.05),

        // Ch 5  Karma Sanyasa — Rose Blush + Mint
        VersePalette(id: 4,
            color1: Color(red: 0.99, green: 0.88, blue: 0.91),
            color2: Color(red: 0.75, green: 0.96, blue: 0.87),
            grainOpacity: 0.05),

        // Ch 6  Dhyana Yoga — Lavender Rose + Soft Violet
        VersePalette(id: 5,
            color1: Color(red: 0.97, green: 0.85, blue: 0.95),
            color2: Color(red: 0.84, green: 0.78, blue: 0.98),
            grainOpacity: 0.05),

        // Ch 7  Jnana Vijnana — Warm Sand + Light Teal
        VersePalette(id: 6,
            color1: Color(red: 0.97, green: 0.92, blue: 0.83),
            color2: Color(red: 0.71, green: 0.94, blue: 0.93),
            grainOpacity: 0.05),

        // Ch 8  Akshar Brahma — Pearl + Slate Blue
        VersePalette(id: 7,
            color1: Color(red: 0.95, green: 0.93, blue: 0.98),
            color2: Color(red: 0.70, green: 0.78, blue: 0.97),
            grainOpacity: 0.05),

        // Ch 9  Raja Vidya — Soft Pink + Lilac
        VersePalette(id: 8,
            color1: Color(red: 0.99, green: 0.83, blue: 0.93),
            color2: Color(red: 0.87, green: 0.78, blue: 0.98),
            grainOpacity: 0.05),

        // Ch 10 Vibhuti Yoga — Cream + Deeper Violet
        VersePalette(id: 9,
            color1: Color(red: 0.97, green: 0.94, blue: 0.91),
            color2: Color(red: 0.81, green: 0.73, blue: 0.98),
            grainOpacity: 0.05),

        // Ch 11 Vishwarupa — Dusty Blush + Cornflower
        VersePalette(id: 10,
            color1: Color(red: 0.97, green: 0.87, blue: 0.92),
            color2: Color(red: 0.66, green: 0.76, blue: 0.98),
            grainOpacity: 0.05),

        // Ch 12 Bhakti Yoga — Warm Rose + Sky Blue
        VersePalette(id: 11,
            color1: Color(red: 1.00, green: 0.83, blue: 0.88),
            color2: Color(red: 0.71, green: 0.86, blue: 0.98),
            grainOpacity: 0.05),

        // Ch 13 Kshetra Kshetrajna — Warm Ivory + Moss
        VersePalette(id: 12,
            color1: Color(red: 0.97, green: 0.96, blue: 0.89),
            color2: Color(red: 0.73, green: 0.92, blue: 0.75),
            grainOpacity: 0.05),

        // Ch 14 Gunatray Vibhaga — Warm Peach + Forest Sage
        VersePalette(id: 13,
            color1: Color(red: 0.99, green: 0.87, blue: 0.79),
            color2: Color(red: 0.80, green: 0.93, blue: 0.82),
            grainOpacity: 0.05),

        // Ch 15 Purushottama — Cream + Cerulean
        VersePalette(id: 14,
            color1: Color(red: 0.97, green: 0.94, blue: 0.93),
            color2: Color(red: 0.65, green: 0.87, blue: 1.00),
            grainOpacity: 0.05),

        // Ch 16 Daivi Sampat — Mint White + Teal
        VersePalette(id: 15,
            color1: Color(red: 0.88, green: 0.98, blue: 0.95),
            color2: Color(red: 0.63, green: 0.93, blue: 0.88),
            grainOpacity: 0.05),

        // Ch 17 Shraddha Traya — Warm Peach + Soft Lavender
        VersePalette(id: 16,
            color1: Color(red: 1.00, green: 0.89, blue: 0.84),
            color2: Color(red: 0.87, green: 0.80, blue: 0.98),
            grainOpacity: 0.05),

        // Ch 18 Moksha Sanyasa — Violet White + Deep Violet
        VersePalette(id: 17,
            color1: Color(red: 0.93, green: 0.89, blue: 0.99),
            color2: Color(red: 0.72, green: 0.66, blue: 0.98),
            grainOpacity: 0.05),
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
                    .blendMode(.multiply)
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

// MARK: - Full-Screen Mesh Gradient Background
// Uses MeshGradient (iOS 18+) for a smooth, organic dual-hue diagonal blend:
// color1 bleeds from the top-leading corner, color2 from the bottom-trailing corner,
// with near-white in the remaining corners and center — exactly like the reference.

struct VerseBackgroundView: View {
    let palette: VersePalette

    var body: some View {
        ZStack {
            meshBackground
            GrainOverlay(opacity: palette.grainOpacity)
        }
        .ignoresSafeArea()
    }

    private var meshBackground: some View {
        let b = VersePalette.base
        let c1 = palette.color1
        let c2 = palette.color2
        return MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ],
            colors: [
                c1,                        // top-left  — full hue 1
                c1.mix(with: b, by: 0.35), // top-center
                b,                         // top-right — base white
                c1.mix(with: b, by: 0.35), // mid-left
                b,                         // center    — base white
                c2.mix(with: b, by: 0.35), // mid-right
                b,                         // bottom-left — base white
                c2.mix(with: b, by: 0.35), // bottom-center
                c2,                        // bottom-right — full hue 2
            ],
            background: VersePalette.base
        )
        .ignoresSafeArea()
    }
}
