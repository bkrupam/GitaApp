import SwiftUI

/// Calm pastel poster — soft chapter hue, dark serif headline, easy on the eyes.
struct CardFrontView: View {
    let item: VerseItem
    var palette: VersePalette? = nil

    private var resolvedPalette: VersePalette { palette ?? item.palette }

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(resolvedPalette.pastelCardSurface)

            VStack(alignment: .leading, spacing: 0) {
                chapterChip
                    .padding(.bottom, 24)

                Spacer(minLength: 0)

                quoteHeadline

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 28)
            .padding(.top, 28)
            .padding(.bottom, 32)
        }
    }

    // MARK: - Chip

    private var chapterChip: some View {
        Text("CH \(item.verse.chapter) · V \(item.verse.verseNumber)")
            .font(.system(size: 11, weight: .semibold, design: .rounded))
            .tracking(1.1)
            .foregroundStyle(VersePalette.posterInk.opacity(0.72))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background {
                Capsule(style: .continuous)
                    .fill(resolvedPalette.pastelChipSurface)
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(resolvedPalette.pastelChipBorder, lineWidth: 0.8)
                    }
            }
    }

    // MARK: - Headline

    private var quoteHeadline: some View {
        Text(item.verse.quote)
            .font(.system(size: 30, weight: .semibold, design: .serif))
            .foregroundStyle(VersePalette.posterInk)
            .multilineTextAlignment(.leading)
            .lineSpacing(2)
            .frame(maxWidth: .infinity, alignment: .leading)
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
    .frame(height: 540)
    .padding(24)
    .background(VerseBackgroundView(palette: VersePalette.all[0]).ignoresSafeArea())
}
