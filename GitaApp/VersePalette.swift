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

    var softFog: Color { color1.blended(with: baseTint, fraction: 0.12) }
    var deepFog: Color { color2.blended(with: baseTint, fraction: 0.12) }

    var onPaletteText: Color { .primary }

    // MARK: Dark → vibrant canvas (verse browsing)

    /// Pure near-black at the very top.
    static let canvasTop = Color(red: 0.04, green: 0.04, blue: 0.07)

    /// Mid-screen: chapter hue, heavily mixed with dark so transition is subtle.
    var canvasMid: Color {
        color2.coolVibrantAccent.blended(with: Self.canvasTop, fraction: 0.82)
    }

    /// Bottom: chapter hue but still quite dark — blends with the overall dark canvas.
    var canvasBottom: Color {
        color2.coolVibrantAccent.blended(with: Self.canvasTop, fraction: 0.45)
    }

    /// Frost on cards — same family as the canvas, slightly lifted for readability.
    var cardFrostTint: Color {
        canvasBottom.blended(with: canvasMid, fraction: 0.35)
    }

    /// Type on cards — soft white with a hint of chapter hue (not flat #FFF).
    var cardPrimaryText: Color {
        Color.white.blended(with: cardFrostTint, fraction: 0.14)
    }

    var cardSecondaryText: Color {
        Color.white.blended(with: cardFrostTint, fraction: 0.22).opacity(0.58)
    }

    var cardLabelText: Color {
        Color.white.blended(with: cardFrostTint, fraction: 0.16).opacity(0.52)
    }

    /// CH · V chip — needs more contrast than section labels.
    var cardChipText: Color {
        Color.white.blended(with: cardFrostTint, fraction: 0.08).opacity(0.82)
    }

    // MARK: Calm pastel poster (eSIM-style — monochromatic tiers, no white cards)

    /// Shared near-white base — never pure #FFF on screen or card.
    private static let pastelCanvasBase = Color(red: 0.976, green: 0.978, blue: 0.984)

    /// Outermost screen — faintest chapter whisper (~3–5% mix).
    var pastelBackground: Color {
        Self.pastelCanvasBase.blended(with: color1.coolVibrantAccent, fraction: 0.05)
    }

    /// Header / frame “well” behind the stack — richer same hue (~24% mix).
    var pastelCanvasFrame: Color {
        Self.pastelCanvasBase.blended(with: color1.coolVibrantAccent, fraction: 0.24)
    }

    /// Card face — tinted light panel (~10% mix), not white; sits on the frame layer.
    var pastelCardSurface: Color {
        Self.pastelCanvasBase.blended(with: color1.coolVibrantAccent, fraction: 0.10)
    }

    /// CH · V chip — one step richer than the card for legibility.
    var pastelChipSurface: Color {
        Self.pastelCanvasBase.blended(with: color1.coolVibrantAccent, fraction: 0.15)
    }

    var pastelChipBorder: Color {
        color2.coolVibrantAccent.opacity(0.18)
    }

    /// Soft shadow tint (chapter hue, not a stroke).
    var pastelCardShadow: Color {
        color2.coolVibrantAccent.opacity(0.12)
    }

    // Typography
    static let posterInk      = Color(red: 0.08, green: 0.10, blue: 0.14)
    static let posterInkMuted = Color(red: 0.08, green: 0.10, blue: 0.14).opacity(0.55)
    static let posterInkFaint = Color(red: 0.08, green: 0.10, blue: 0.14).opacity(0.38)
}

// MARK: - Chapter Palettes
// Distinct chapter identity — warm gold/orange for early chapters, cool blues and violets after.

extension VersePalette {

    static let all: [VersePalette] = [

        // Ch 1  Arjuna Vishada — warm golden yellow (distinct from ch4 violet)
        VersePalette(id: 0,
            baseTint: Color(red: 0.978, green: 0.972, blue: 0.948),
            color1: Color(red: 0.90, green: 0.82, blue: 0.50),
            color2: Color(red: 0.86, green: 0.74, blue: 0.34),
            grainOpacity: 0.04),

        // Ch 2  Sankhya Yoga — clarity, the eternal → cool cobalt (cyan-blue, not violet)
        VersePalette(id: 1,
            baseTint: Color(red: 0.948, green: 0.962, blue: 0.978),
            color1: Color(red: 0.10, green: 0.58, blue: 0.92),
            color2: Color(red: 0.06, green: 0.54, blue: 0.90),
            grainOpacity: 0.04),

        // Ch 3  Karma Yoga — selfless action → soft red (distinct from ch2 blue)
        VersePalette(id: 2,
            baseTint: Color(red: 0.978, green: 0.954, blue: 0.952),
            color1: Color(red: 0.92, green: 0.58, blue: 0.56),
            color2: Color(red: 0.86, green: 0.40, blue: 0.42),
            grainOpacity: 0.04),

        // Ch 4  Jnana Yoga — fire of knowledge, renunciation → deep violet
        VersePalette(id: 3,
            baseTint: Color(red: 0.958, green: 0.952, blue: 0.976),
            color1: Color(red: 0.56, green: 0.30, blue: 0.84),
            color2: Color(red: 0.52, green: 0.26, blue: 0.82),
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

// MARK: - Calm pastel canvas

/// eSIM-style canvas: pale edges, richer monochromatic “well” behind the cards.
struct VerseBackgroundView: View {
    let palette: VersePalette

    var body: some View {
        ZStack {
            palette.pastelBackground

            LinearGradient(
                stops: [
                    .init(color: palette.pastelCanvasFrame.opacity(0.54), location: 0),
                    .init(color: palette.pastelCanvasFrame.opacity(0.78), location: 0.34),
                    .init(color: palette.pastelBackground, location: 1),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Color helpers


extension Color {
    func blended(with other: Color, fraction: Double) -> Color {
        let a = UIColor(self)
        let b = UIColor(other)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        a.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        b.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let t = CGFloat(min(max(fraction, 0), 1))
        return Color(
            red: Double(r1 + (r2 - r1) * t),
            green: Double(g1 + (g2 - g1) * t),
            blue: Double(b1 + (b2 - b1) * t),
            opacity: Double(a1 + (a2 - a1) * t)
        )
    }

    func saturated(by factor: Double) -> Color {
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        if s < 0.01 { return self }
        return Color(
            hue: Double(h),
            saturation: Double(min(1, s * factor)),
            brightness: Double(min(1, b * 1.04)),
            opacity: Double(a)
        )
    }

    /// Nudges sage / yellow-green hues toward blue for later chapters; keeps gold and orange intact.
    var coolVibrantAccent: Color {
        let ui = UIColor(self)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        guard s > 0.04 else { return self }

        // Preserve red, orange, and gold (ch 1–3); only cool down greenish yellows.
        let isShiftableYellowGreen = h >= 0.22 && h <= 0.48
        if isShiftableYellowGreen {
            let target: CGFloat = h < 0.28 ? 0.58 : 0.72
            h = h * 0.25 + target * 0.75
            s = min(1, s * 1.08)
        }
        return Color(hue: Double(h), saturation: Double(s), brightness: Double(b), opacity: Double(a))
    }
}
