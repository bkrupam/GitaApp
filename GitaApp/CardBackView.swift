import SwiftUI

/// Calm pastel back of the card — sanskrit, scene, takeaway, learn-more action.
struct CardBackView: View {
    let item: VerseItem
    var palette: VersePalette? = nil
    let onAskMore: () -> Void

    private var resolvedPalette: VersePalette { palette ?? item.palette }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(resolvedPalette.pastelCardSurface)

            VStack(spacing: 0) {
                scrollContent
                learnMoreButton
            }
        }
    }

    private var scrollContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                Text(item.verse.shlok)
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .italic()
                    .foregroundStyle(VersePalette.posterInkMuted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity)

                divider.padding(.vertical, 22)

                label("THE SCENE")
                Text(item.verse.scene)
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundStyle(VersePalette.posterInk)
                    .lineSpacing(5)
                    .padding(.top, 6)

                divider.padding(.vertical, 22)

                label("THE TAKEAWAY")
                Text(item.verse.takeaway)
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundStyle(VersePalette.posterInk)
                    .lineSpacing(5)
                    .padding(.top, 6)
            }
            .padding(.horizontal, 28)
            .padding(.top, 32)
            .padding(.bottom, 16)
        }
        .mask(
            VStack(spacing: 0) {
                Rectangle().fill(Color.black)
                LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                    .frame(height: 32)
            }
        )
    }

    private var learnMoreButton: some View {
        Button(action: onAskMore) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 12, weight: .semibold))
                Text("Learn more")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .tracking(0.4)
            }
            .foregroundStyle(Color.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(VersePalette.posterInk)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .padding(.top, 8)
    }

    private var divider: some View {
        Rectangle()
            .fill(VersePalette.posterInk.opacity(0.10))
            .frame(height: 0.8)
    }

    private func label(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 10, weight: .semibold, design: .rounded))
            .foregroundStyle(VersePalette.posterInkFaint)
            .tracking(1.4)
    }
}
