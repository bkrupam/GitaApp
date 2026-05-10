import SwiftUI

struct CardBackView: View {
    let item: VerseItem
    let onAskMore: () -> Void

    var body: some View {
        ZStack {
            // ── Light glass surface ─────────────────────────────────────────
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)

            // Inner top highlight
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

            // ── Content ────────────────────────────────────────────────────
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
                        label("THE SCENE")
                        Text(item.verse.scene)
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundStyle(Color.primary)
                            .lineSpacing(5)
                            .padding(.top, 6)

                        divider.padding(.vertical, 20)

                        // ── The Takeaway ─────────────────────────────────
                        label("THE TAKEAWAY")
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
                // Fade long content at the bottom of the card using the background color (approx)
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

                // ── Learn more button ─────────────────────────────────────
                Button(action: onAskMore) {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 12, weight: .semibold))
                        Text("Learn more")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(Color.primary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 11)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.primary.opacity(0.05))
                            .overlay(
                                Capsule(style: .continuous)
                                    .strokeBorder(Color.primary.opacity(0.12), lineWidth: 0.8)
                            )
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
            .fill(Color.primary.opacity(0.08))
            .frame(height: 0.8)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .bold, design: .rounded))
            .foregroundStyle(Color.secondary.opacity(0.7))
            .tracking(1.4)
    }
}
