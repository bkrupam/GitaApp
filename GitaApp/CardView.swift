import SwiftUI

// MARK: - AnimatableModifier for precise flip visibility

/// Rotates a view around the Y axis and hides it whenever it is
/// facing away (rotation outside ±90°), so only the correct face shows.
private struct FlipSide: AnimatableModifier {
    var rotation: Double   // degrees, positive = clockwise when viewed from front

    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }

    func body(content: Content) -> some View {
        content
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0, y: 1, z: 0),
                perspective: 0.35
            )
            // Hide the face while it's pointing away from the viewer
            .opacity(isFacingViewer ? 1 : 0)
    }

    private var isFacingViewer: Bool {
        // Normalise to [0, 360)
        let normalised = rotation.truncatingRemainder(dividingBy: 360)
        let positive = normalised < 0 ? normalised + 360 : normalised
        // Visible when within ±90° of facing forward (0°/360°)
        return positive < 90 || positive > 270
    }
}

// MARK: - CardView

struct CardView: View {
    let item: VerseItem
    let isActive: Bool
    var onAskMore: () -> Void = {}

    @State private var isFlipped = false

    // Spring used for the flip — feels satisfying and physical
    private let flipSpring = Animation.spring(response: 0.55, dampingFraction: 0.72)

    var body: some View {
        ZStack {
            // Back face — starts rotated 180° (hidden behind front)
            CardBackView(item: item, onAskMore: onAskMore)
                .modifier(FlipSide(rotation: isFlipped ? 0 : 180))

            // Front face — starts at 0° (facing viewer)
            CardFrontView(item: item)
                .modifier(FlipSide(rotation: isFlipped ? -180 : 0))
        }
        // Shadow lives on the container so it never flickers during the flip
        .shadow(color: .black.opacity(0.08), radius: 24, x: 0, y: 12)
        .shadow(color: .black.opacity(0.04), radius: 8,  x: 0, y: 3)
        // Scale non-active cards down slightly for depth effect
        .scaleEffect(isActive ? 1.0 : 0.93)
        .opacity(isActive ? 1.0 : 0.65)
        .animation(.spring(response: 0.4, dampingFraction: 0.82), value: isActive)
        .onTapGesture {
            guard isActive else { return }
            withAnimation(flipSpring) {
                isFlipped.toggle()
            }
        }
        // Reset to front when card leaves view / becomes inactive
        .onChange(of: isActive) { active in
            if !active && isFlipped {
                // Instantly reset without animation so it's fresh on return
                isFlipped = false
            }
        }
    }
}

#Preview {
    let item = VerseItem(
        id: 1,
        verse: Verse(
            id: 1, chapter: 1, verseNumber: "1",
            quote: "The man in power never asks what's right. He asks who's winning.",
            shlok: "dharma-kṣhetre kuru-kṣhetre samavetā yuyutsavaḥ",
            scene: "Dhritarashtra asks Sanjaya what happened on the battlefield.",
            takeaway: "Our first questions reveal our deepest loyalties — and our deepest blind spots."
        ),
        paletteID: 0
    )
    CardView(item: item, isActive: true)
        .frame(height: 520)
        .padding(24)
        .background(VerseBackgroundView(palette: VersePalette.all[0]).ignoresSafeArea())
}
