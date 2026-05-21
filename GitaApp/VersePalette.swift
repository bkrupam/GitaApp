import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

// MARK: - Verse Palette

struct VersePalette: Identifiable {
    let id: Int
    let baseTint: Color   // cool canvas — visible chapter identity
    let color1: Color     // soft accent (lighter cool hue)
    let color2: Color     // deep accent (richer cool hue)
    let grainOpacity: Double

    /// Neutral fallback (e.g. mood results, previews).
    static let base = Color(red: 0.958, green: 0.962, blue: 0.972)

    var softFog: Color { color1.mix(with: baseTint, by: 0.12) }
    var deepFog: Color { color2.mix(with: baseTint, by: 0.12) }

    var onPaletteText: Color { .primary }
}

// MARK: - Chapter Palettes
// Cool, soothing pairs — lavender, slate, sage, mist, ocean, violet.
// No warm yellows/golds. Each chapter gets a distinct baseTint + accent pair.

extension VersePalette {

    static let all: [VersePalette] = [

        // Ch 1  Arjuna Vishada — Dusty rose + Sky
        VersePalette(id: 0,
            baseTint: Color(red: 0.964, green: 0.958, blue: 0.972),
            color1: Color(red: 0.82, green: 0.72, blue: 0.82),
            color2: Color(red: 0.62, green: 0.74, blue: 0.88),
            grainOpacity: 0.04),

        // Ch 2  Sankhya Yoga — Lavender + Periwinkle
        VersePalette(id: 1,
            baseTint: Color(red: 0.956, green: 0.958, blue: 0.978),
            color1: Color(red: 0.78, green: 0.72, blue: 0.90),
            color2: Color(red: 0.58, green: 0.66, blue: 0.86),
            grainOpacity: 0.04),

        // Ch 3  Karma Yoga — Mint + Sage
        VersePalette(id: 2,
            baseTint: Color(red: 0.946, green: 0.966, blue: 0.960),
            color1: Color(red: 0.68, green: 0.84, blue: 0.78),
            color2: Color(red: 0.52, green: 0.72, blue: 0.66),
            grainOpacity: 0.04),

        // Ch 4  Jnana Karma Sanyasa — Ice + Steel
        VersePalette(id: 3,
            baseTint: Color(red: 0.946, green: 0.960, blue: 0.976),
            color1: Color(red: 0.72, green: 0.82, blue: 0.90),
            color2: Color(red: 0.48, green: 0.62, blue: 0.78),
            grainOpacity: 0.04),

        // Ch 5  Karma Sanyasa — Lilac + Seafoam
        VersePalette(id: 4,
            baseTint: Color(red: 0.952, green: 0.960, blue: 0.972),
            color1: Color(red: 0.76, green: 0.70, blue: 0.88),
            color2: Color(red: 0.58, green: 0.78, blue: 0.76),
            grainOpacity: 0.04),

        // Ch 6  Dhyana Yoga — Orchid + Twilight
        VersePalette(id: 5,
            baseTint: Color(red: 0.948, green: 0.954, blue: 0.976),
            color1: Color(red: 0.74, green: 0.66, blue: 0.86),
            color2: Color(red: 0.50, green: 0.54, blue: 0.78),
            grainOpacity: 0.04),

        // Ch 7  Jnana Vijnana — Moonlight + Cyan
        VersePalette(id: 6,
            baseTint: Color(red: 0.944, green: 0.962, blue: 0.972),
            color1: Color(red: 0.70, green: 0.82, blue: 0.88),
            color2: Color(red: 0.44, green: 0.70, blue: 0.76),
            grainOpacity: 0.04),

        // Ch 8  Akshar Brahma — Pearl + Cornflower
        VersePalette(id: 7,
            baseTint: Color(red: 0.950, green: 0.956, blue: 0.972),
            color1: Color(red: 0.78, green: 0.78, blue: 0.88),
            color2: Color(red: 0.52, green: 0.62, blue: 0.84),
            grainOpacity: 0.04),

        // Ch 9  Raja Vidya — Pink mist + Amethyst
        VersePalette(id: 8,
            baseTint: Color(red: 0.960, green: 0.956, blue: 0.972),
            color1: Color(red: 0.84, green: 0.70, blue: 0.82),
            color2: Color(red: 0.62, green: 0.56, blue: 0.80),
            grainOpacity: 0.04),

        // Ch 10 Vibhuti Yoga — Wisteria + Indigo
        VersePalette(id: 9,
            baseTint: Color(red: 0.946, green: 0.954, blue: 0.976),
            color1: Color(red: 0.72, green: 0.68, blue: 0.86),
            color2: Color(red: 0.46, green: 0.50, blue: 0.72),
            grainOpacity: 0.04),

        // Ch 11 Vishwarupa — Mauve + Horizon
        VersePalette(id: 10,
            baseTint: Color(red: 0.954, green: 0.956, blue: 0.970),
            color1: Color(red: 0.78, green: 0.68, blue: 0.78),
            color2: Color(red: 0.50, green: 0.68, blue: 0.84),
            grainOpacity: 0.04),

        // Ch 12 Bhakti Yoga — Rose quartz + Azure
        VersePalette(id: 11,
            baseTint: Color(red: 0.958, green: 0.958, blue: 0.974),
            color1: Color(red: 0.82, green: 0.68, blue: 0.76),
            color2: Color(red: 0.48, green: 0.66, blue: 0.86),
            grainOpacity: 0.04),

        // Ch 13 Kshetra Kshetrajna — Eucalyptus + Forest mist
        VersePalette(id: 12,
            baseTint: Color(red: 0.942, green: 0.962, blue: 0.954),
            color1: Color(red: 0.62, green: 0.78, blue: 0.72),
            color2: Color(red: 0.48, green: 0.66, blue: 0.58),
            grainOpacity: 0.04),

        // Ch 14 Gunatray Vibhaga — Blue-grey + Mint frost
        VersePalette(id: 13,
            baseTint: Color(red: 0.944, green: 0.960, blue: 0.966),
            color1: Color(red: 0.62, green: 0.72, blue: 0.80),
            color2: Color(red: 0.56, green: 0.76, blue: 0.72),
            grainOpacity: 0.04),

        // Ch 15 Purushottama — Cool shell + Cerulean
        VersePalette(id: 14,
            baseTint: Color(red: 0.948, green: 0.960, blue: 0.968),
            color1: Color(red: 0.74, green: 0.78, blue: 0.82),
            color2: Color(red: 0.40, green: 0.64, blue: 0.82),
            grainOpacity: 0.04),

        // Ch 16 Daivi Sampat — Sea glass + Jade mist
        VersePalette(id: 15,
            baseTint: Color(red: 0.936, green: 0.966, blue: 0.958),
            color1: Color(red: 0.58, green: 0.80, blue: 0.74),
            color2: Color(red: 0.42, green: 0.68, blue: 0.62),
            grainOpacity: 0.04),

        // Ch 17 Shraddha Traya — Soft lavender + Blue haze
        VersePalette(id: 16,
            baseTint: Color(red: 0.950, green: 0.958, blue: 0.976),
            color1: Color(red: 0.76, green: 0.72, blue: 0.88),
            color2: Color(red: 0.54, green: 0.64, blue: 0.82),
            grainOpacity: 0.04),

        // Ch 18 Moksha Sanyasa — Iris + Deep violet
        VersePalette(id: 17,
            baseTint: Color(red: 0.946, green: 0.948, blue: 0.974),
            color1: Color(red: 0.68, green: 0.62, blue: 0.84),
            color2: Color(red: 0.44, green: 0.40, blue: 0.72),
            grainOpacity: 0.04),
    ]

    // MARK: Mood results — cool palettes aligned with the verses home screen

    /// Default when chat results come from free text (no mood tile).
    static let freeTextResults = VersePalette(
        id: 200,
        baseTint: Color(red: 0.948, green: 0.960, blue: 0.974),
        color1: Color(red: 0.72, green: 0.80, blue: 0.90),
        color2: Color(red: 0.52, green: 0.66, blue: 0.84),
        grainOpacity: 0.04
    )

    /// Cool, soothing palette for each mood's verse results screen.
    static func forMood(_ mood: Mood) -> VersePalette {
        switch mood.id {
        case "anxious":
            return VersePalette(id: 101,
                baseTint: Color(red: 0.952, green: 0.958, blue: 0.976),
                color1: Color(red: 0.76, green: 0.74, blue: 0.90),
                color2: Color(red: 0.56, green: 0.68, blue: 0.86),
                grainOpacity: 0.04)
        case "heartbroken":
            return VersePalette(id: 102,
                baseTint: Color(red: 0.964, green: 0.954, blue: 0.962),
                color1: Color(red: 0.82, green: 0.68, blue: 0.76),
                color2: Color(red: 0.58, green: 0.62, blue: 0.78),
                grainOpacity: 0.04)
        case "angry":
            return VersePalette(id: 103,
                baseTint: Color(red: 0.956, green: 0.952, blue: 0.970),
                color1: Color(red: 0.78, green: 0.66, blue: 0.76),
                color2: Color(red: 0.50, green: 0.58, blue: 0.76),
                grainOpacity: 0.04)
        case "tired":
            return VersePalette(id: 104,
                baseTint: Color(red: 0.950, green: 0.956, blue: 0.972),
                color1: Color(red: 0.74, green: 0.76, blue: 0.88),
                color2: Color(red: 0.52, green: 0.62, blue: 0.78),
                grainOpacity: 0.04)
        case "overwhelmed":
            return VersePalette(id: 105,
                baseTint: Color(red: 0.944, green: 0.952, blue: 0.970),
                color1: Color(red: 0.68, green: 0.72, blue: 0.84),
                color2: Color(red: 0.48, green: 0.60, blue: 0.76),
                grainOpacity: 0.04)
        case "curious":
            return VersePalette(id: 106,
                baseTint: Color(red: 0.948, green: 0.952, blue: 0.976),
                color1: Color(red: 0.72, green: 0.66, blue: 0.88),
                color2: Color(red: 0.50, green: 0.56, blue: 0.80),
                grainOpacity: 0.04)
        case "grateful":
            return VersePalette(id: 107,
                baseTint: Color(red: 0.944, green: 0.968, blue: 0.962),
                color1: Color(red: 0.66, green: 0.82, blue: 0.76),
                color2: Color(red: 0.56, green: 0.72, blue: 0.88),
                grainOpacity: 0.04)
        case "calm":
            return VersePalette(id: 108,
                baseTint: Color(red: 0.938, green: 0.968, blue: 0.958),
                color1: Color(red: 0.60, green: 0.82, blue: 0.74),
                color2: Color(red: 0.48, green: 0.70, blue: 0.66),
                grainOpacity: 0.04)
        case "sad":
            return VersePalette(id: 109,
                baseTint: Color(red: 0.946, green: 0.960, blue: 0.976),
                color1: Color(red: 0.70, green: 0.80, blue: 0.92),
                color2: Color(red: 0.48, green: 0.62, blue: 0.82),
                grainOpacity: 0.04)
        case "stuck":
            return VersePalette(id: 110,
                baseTint: Color(red: 0.946, green: 0.958, blue: 0.974),
                color1: Color(red: 0.64, green: 0.72, blue: 0.88),
                color2: Color(red: 0.44, green: 0.54, blue: 0.76),
                grainOpacity: 0.04)
        case "lost":
            return VersePalette(id: 111,
                baseTint: Color(red: 0.948, green: 0.958, blue: 0.968),
                color1: Color(red: 0.66, green: 0.72, blue: 0.80),
                color2: Color(red: 0.46, green: 0.64, blue: 0.78),
                grainOpacity: 0.04)
        case "hopeful":
            return VersePalette(id: 112,
                baseTint: Color(red: 0.958, green: 0.958, blue: 0.974),
                color1: Color(red: 0.78, green: 0.68, blue: 0.82),
                color2: Color(red: 0.50, green: 0.66, blue: 0.86),
                grainOpacity: 0.04)
        default:
            return freeTextResults
        }
    }
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

// MARK: - Drifting Fog Background (Option A)
// Tinted chapter base + two soft colour clouds that drift diagonally.
// Heavy blur removes hard edges; a centre vignette keeps the card zone calm.

struct VerseBackgroundView: View {
    let palette: VersePalette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Seconds for one full diagonal drift cycle.
    private let cycleDuration = 15.0

    var body: some View {
        ZStack {
            if reduceMotion {
                fogLayer(time: 0)
            } else {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    fogLayer(time: timeline.date.timeIntervalSinceReferenceDate)
                }
            }
            GrainOverlay(opacity: palette.grainOpacity)
        }
        .ignoresSafeArea()
    }

    private func fogLayer(time: Double) -> some View {
        GeometryReader { geo in
            let blur = max(geo.size.width, geo.size.height) * 0.15
            let t = time * (2 * Double.pi / cycleDuration)

            // Warm mist drifts SE; cool mist drifts NW — one slow diagonal pass.
            let warmCenter = UnitPoint(
                x: 0.04 + 0.30 * (0.5 + 0.5 * sin(t)),
                y: 0.02 + 0.24 * (0.5 + 0.5 * sin(t + 0.35))
            )
            let coolCenter = UnitPoint(
                x: 0.96 - 0.30 * (0.5 + 0.5 * sin(t)),
                y: 0.98 - 0.24 * (0.5 + 0.5 * sin(t + 0.35))
            )

            ZStack {
                palette.baseTint

                ZStack {
                    EllipticalGradient(
                        colors: [
                            palette.softFog.opacity(0.78),
                            palette.softFog.opacity(0.42),
                            .clear,
                        ],
                        center: warmCenter,
                        startRadiusFraction: 0,
                        endRadiusFraction: 0.72
                    )

                    EllipticalGradient(
                        colors: [
                            palette.deepFog.opacity(0.74),
                            palette.deepFog.opacity(0.38),
                            .clear,
                        ],
                        center: coolCenter,
                        startRadiusFraction: 0,
                        endRadiusFraction: 0.70
                    )
                }
                .blur(radius: blur)

                // Soft centre lift — keeps cards readable without killing edge colour.
                EllipticalGradient(
                    colors: [
                        palette.baseTint.opacity(0.72),
                        palette.baseTint.opacity(0.28),
                        .clear,
                    ],
                    center: .center,
                    startRadiusFraction: 0,
                    endRadiusFraction: 0.46
                )
            }
        }
        .ignoresSafeArea()
    }
}
