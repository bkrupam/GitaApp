import SwiftUI

// MARK: - MoodCardView

private let moodCardCorner: CGFloat = 24

struct MoodCardView: View {
    let mood: Mood

    var body: some View {
        ZStack(alignment: .bottom) {

            // ── Base fill + diagonal gradient overlay (bright top-left → deep bottom-right) ──
            mood.color
            LinearGradient(
                colors: [
                    .white.opacity(0.30),
                    .clear,
                    .black.opacity(0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // ── Illustration ─────────────────────────────────────────────────
            // No blend mode: white PNG background shows as a sticker outline
            // against the dark card, matching the reference style.
            Group {
                if UIImage(named: mood.id) != nil {
                    Image(mood.id)
                        .resizable()
                        .scaledToFit()
                } else {
                    Image(systemName: mood.symbol)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.horizontal, 36)
            .padding(.top, 20)
            .padding(.bottom, 62)        // room for gradient + label band

            // ── Bottom gradient fade — fades into the darkened bottom-right tone ──
            LinearGradient(
                stops: [
                    .init(color: .clear,                          location: 0.00),
                    .init(color: .black.opacity(0.20),            location: 0.28),
                    .init(color: .black.opacity(0.52),            location: 0.72),
                    .init(color: .black.opacity(0.62),            location: 1.00),
                ],
                startPoint: .top,
                endPoint:   .bottom
            )
            .frame(height: 92)
            .allowsHitTesting(false)

            // ── Label ─────────────────────────────────────────────────────────
            Text(mood.label)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .padding(.top, 6)
                .padding(.bottom, 22)
        }
        .aspectRatio(0.88, contentMode: .fit)
        .contentShape(RoundedRectangle(cornerRadius: moodCardCorner, style: .continuous))
        .clipShape(RoundedRectangle(cornerRadius: moodCardCorner, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: moodCardCorner, style: .continuous)
                .strokeBorder(.white.opacity(0.12), lineWidth: 1)
        }
        .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 7)
    }
}

// MARK: - Press-scale button style

/// Shrinks the card slightly on press — applied at the NavigationLink/Button level.
struct MoodCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
        ForEach(Mood.all.prefix(4)) { mood in
            MoodCardView(mood: mood)
        }
    }
    .padding(24)
}
