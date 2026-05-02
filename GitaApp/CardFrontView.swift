import SwiftUI

struct CardFrontView: View {
    let item: VerseItem

    var body: some View {
        ZStack {
            // Card surface
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(item.tintColor)

            // Colored border
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(item.color.opacity(0.55), lineWidth: 1.5)

            // Quote text
            Text(item.verse.quote)
                .font(.system(size: 26, weight: .heavy, design: .rounded))
                .foregroundStyle(item.color)
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 36)
                .padding(.vertical, 48)
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
        color: Color(red: 0.940, green: 0.260, blue: 0.260),
        tintColor: Color(red: 1.000, green: 0.940, blue: 0.940)
    ))
    .frame(height: 500)
    .padding(24)
}
