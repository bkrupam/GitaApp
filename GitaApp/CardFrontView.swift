import SwiftUI

struct CardFrontView: View {
    let item: VerseItem

    var body: some View {
        ZStack {
            // ── Light glass surface ─────────────────────────────────────────
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)

            // Inner top highlight for glass edge
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.8), .clear],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.4)
                    )
                )

            // Very subtle dark border to clearly define the card edge on a light background
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.8)

            // ── Content ─────────────────────────────────────────────────────
            VStack(spacing: 0) {

                // Chapter · Verse chip
                Text("CH \(item.verse.chapter)  ·  V \(item.verse.verseNumber)")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .tracking(2.0)
                    .foregroundStyle(Color.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.primary.opacity(0.04))
                            .overlay(
                                Capsule(style: .continuous)
                                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.7)
                            )
                    )

                Spacer()

                // Main quote — dominant hierarchy
                Text(item.verse.quote)
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.primary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(7)
                    // Very subtle shadow for text depth on light background
                    .shadow(color: .white.opacity(0.6), radius: 2, x: 0, y: 1)

                Spacer()
            }
            .padding(.horizontal, 32)
            .padding(.vertical, 36)
        }
    }
}

#Preview {
    CardFrontView(item: VerseItem(
        id: 1,
        verse: Verse(
            id: 1, chapter: 1, verseNumber: "1",
            quote: "The man in power never asks what's right. He asks who's winning.",
            shlok: "dharma-kṣhetre kuru-kṣhetre samavetā yuyutsavaḥ",
            scene: "Dhritarashtra asks Sanjaya what happened on the battlefield.",
            takeaway: "Our first questions reveal our deepest loyalties."
        ),
        paletteID: 0
    ))
    .frame(height: 500)
    .padding(24)
    .background(VerseBackgroundView(palette: VersePalette.all[0]).ignoresSafeArea())
}
