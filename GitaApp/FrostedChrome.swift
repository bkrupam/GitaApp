import SwiftUI

// MARK: - Canvas frost
// Cards are tinted with the chapter hue (not flat white), so they read as part of the gradient.

enum GitaFrosted {
    static let cardCornerRadius: CGFloat = 24
    static let cardTintOpacity: Double = 0.22
    static let cardSheenOpacity: Double = 0.05
    static let borderWidth: CGFloat = 0.75

    static let chromeFill  = Color.white.opacity(0.12)
    static let chromeBorder = Color.white.opacity(0.22)
    static let pillActive  = Color.white.opacity(0.18)

    /// Chrome labels (tab bar, FAB) — neutral frost on canvas, not chapter cards.
    static let text        = Color.white.opacity(0.94)
    static let textFaint   = Color.white.opacity(0.55)
    static let textGhost   = Color.white.opacity(0.38)
}

// MARK: - Card surface (chapter-tinted)

struct GitaFrostedCardBackground: View {
    let tint: Color
    var cornerRadius: CGFloat = GitaFrosted.cardCornerRadius

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(tint.opacity(GitaFrosted.cardTintOpacity))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(GitaFrosted.cardSheenOpacity + 0.04),
                                Color.white.opacity(GitaFrosted.cardSheenOpacity),
                                Color.clear,
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.26),
                                Color.white.opacity(0.10),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: GitaFrosted.borderWidth
                    )
            }
    }
}

struct GitaFrostedChipBackground: View {
    let tint: Color

    var body: some View {
        Capsule(style: .continuous)
            .fill(tint.opacity(0.24))
            .overlay {
                Capsule(style: .continuous)
                    .fill(Color.white.opacity(0.06))
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(Color.white.opacity(0.28), lineWidth: 0.65)
            }
    }
}

extension View {
    func gitaFrostedCard(tint: Color, cornerRadius: CGFloat = GitaFrosted.cardCornerRadius) -> some View {
        background {
            GitaFrostedCardBackground(tint: tint, cornerRadius: cornerRadius)
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    func gitaFrostedChip(tint: Color) -> some View {
        background {
            GitaFrostedChipBackground(tint: tint)
        }
    }

    func gitaFrostedCapsule() -> some View {
        background {
            Capsule(style: .continuous)
                .fill(GitaFrosted.chromeFill)
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(GitaFrosted.chromeBorder, lineWidth: GitaFrosted.borderWidth)
                }
        }
    }

    func gitaFrostedCircle() -> some View {
        background {
            Circle()
                .fill(GitaFrosted.chromeFill)
                .overlay {
                    Circle()
                        .strokeBorder(GitaFrosted.chromeBorder, lineWidth: GitaFrosted.borderWidth)
                }
        }
    }
}

typealias CanvasFrost = GitaFrosted
extension GitaFrosted {
    static var primaryText: Color   { text }
    static var secondaryText: Color { textFaint }
    static var tertiaryText: Color  { textGhost }
    static var divider: Color       { Color.white.opacity(0.12) }
}

extension View {
    func gitaVerseCanvasFrost() -> some View { self }
    func gitaVerseCanvasGlass()  -> some View { self }
    func gitaFrostedCard(cornerRadius: CGFloat = GitaFrosted.cardCornerRadius) -> some View {
        gitaFrostedCard(tint: VersePalette.canvasTop, cornerRadius: cornerRadius)
    }
    func gitaCanvasFrostCard(cornerRadius: CGFloat = GitaFrosted.cardCornerRadius) -> some View {
        gitaFrostedCard(cornerRadius: cornerRadius)
    }
    func gitaCanvasChromeCapsule() -> some View { gitaFrostedCapsule() }
    func gitaCanvasChromeCircle()  -> some View { gitaFrostedCircle() }
    func gitaSmokedFrostCard(cornerRadius: CGFloat = GitaFrosted.cardCornerRadius) -> some View {
        gitaFrostedCard(cornerRadius: cornerRadius)
    }
    func gitaSmokedFrostCapsule()  -> some View { gitaFrostedCapsule() }
    func gitaSmokedFrostCircle()   -> some View { gitaFrostedCircle() }
    func gitaCanvasFrostCapsule(strongTint: Bool = false) -> some View { gitaFrostedCapsule() }
    func gitaCanvasFrostCircle()   -> some View { gitaFrostedCircle() }
}
