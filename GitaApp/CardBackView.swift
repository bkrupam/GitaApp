import SwiftUI

struct CardBackView: View {
    let item: VerseItem
    let onAskMore: () -> Void

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(Color(.systemBackground))
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color(.systemGray5), lineWidth: 1)

            VStack(spacing: 0) {
                // Scrollable content so long takeaways are fully readable
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {

                        // ── Transliteration ──────────────────────────────
                        Text(item.verse.shlok)
                            .font(.system(size: 12, weight: .regular, design: .serif))
                            .foregroundStyle(Color.secondary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .frame(maxWidth: .infinity)

                        divider.padding(.vertical, 20)

                        // ── The Scene ────────────────────────────────────
                        label("THE SCENE", color: item.color)
                        Text(item.verse.scene)
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundStyle(Color.primary)
                            .lineSpacing(5)
                            .padding(.top, 6)

                        divider.padding(.vertical, 20)

                        // ── The Takeaway ─────────────────────────────────
                        label("THE TAKEAWAY", color: item.color)
                        Text(item.verse.takeaway)
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundStyle(Color.primary)
                            .lineSpacing(5)
                            .padding(.top, 6)
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 28)
                    .padding(.bottom, 12)
                }
                // Fade long content at the bottom of the card
                .mask(
                    VStack(spacing: 0) {
                        Rectangle().fill(Color.black)
                        LinearGradient(
                            colors: [.black, .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 32)
                    }
                )

                Button(action: onAskMore) {
                    HStack(spacing: 10) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Learn more")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        Capsule(style: .continuous)
                            .fill(item.color)
                    )
                }
                .buttonStyle(.plain)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 28)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
        }
    }

    // MARK: - Helpers

    private var divider: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .frame(height: 1)
    }

    private func label(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(color)
            .tracking(1.2)
    }
}
