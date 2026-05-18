import SwiftUI

struct CardBackView: View {
    let item: VerseItem
    let onAskMore: () -> Void

    var body: some View {
        if #available(iOS 26.0, *) {
            glassCard
        } else {
            legacyCard
        }
    }

    // MARK: - iOS 26 Liquid Glass

    @available(iOS 26.0, *)
    private var glassCard: some View {
        VStack(spacing: 0) {
            scrollContent
            learnMoreButtonGlass
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .glassEffect(Glass.regular, in: RoundedRectangle(cornerRadius: 28, style: .continuous))
    }

    // MARK: - Legacy (< iOS 26)

    private var legacyCard: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [.white.opacity(0.8), .clear],
                        startPoint: .top,
                        endPoint: UnitPoint(x: 0.5, y: 0.4)
                    )
                )
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 0.8)
            VStack(spacing: 0) {
                scrollContent
                learnMoreButtonLegacy
            }
        }
    }

    // MARK: - Shared scroll content

    private var scrollContent: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {

                Text(item.verse.shlok)
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .foregroundStyle(Color.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity)

                divider.padding(.vertical, 20)

                label("THE SCENE")
                Text(item.verse.scene)
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .foregroundStyle(Color.primary)
                    .lineSpacing(5)
                    .padding(.top, 6)

                divider.padding(.vertical, 20)

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
    }

    // MARK: - Learn more button (iOS 26)

    @available(iOS 26.0, *)
    private var learnMoreButtonGlass: some View {
        GlassEffectContainer {
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
            }
            .buttonStyle(.plain)
            .glassEffect(Glass.regular.interactive(), in: Capsule())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 28)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }

    // MARK: - Learn more button (legacy)

    private var learnMoreButtonLegacy: some View {
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
