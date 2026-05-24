import SwiftUI

struct TopTabBar: View {
    @Binding var selectedTab: AppTab
    var glassNamespace: Namespace.ID
    var onVibrantCanvas: Bool = false

    var body: some View {
        tabBarTrack {
            tabButton(.verses, icon: "book.pages", label: "Verses")
            tabButton(.chat,   icon: "bubble.left.and.text.bubble.right", label: "Chat")
        }
    }

    // MARK: - Shared track (one outer pill, both tabs inside)

    @ViewBuilder
    private func tabBarTrack<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        if onVibrantCanvas {
            GitaChrome.glassEffectGroup(spacing: 12) {
                HStack(spacing: 4) {
                    content()
                }
                .padding(4)
                .vibrantCanvasTabTrackGlass(
                    glassID: "topTabBarOuter",
                    glassNamespace: glassNamespace
                )
            }
        } else {
            GitaChrome.glassEffectGroup(spacing: 12) {
                HStack(spacing: 4) {
                    content()
                }
                .padding(4)
                .gitaHeaderCapsuleGlass(
                    glassID: "topTabBarOuter",
                    glassNamespace: glassNamespace
                )
            }
        }
    }

    // MARK: - Tab button (active pill slides inside the track)

    @ViewBuilder
    private func tabButton(_ tab: AppTab, icon: String, label: String) -> some View {
        let active = selectedTab == tab

        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .symbolRenderingMode(.monochrome)

                if active {
                    Text(label)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .transition(.opacity.combined(with: .scale(scale: 0.85, anchor: .leading)))
                }
            }
            .foregroundStyle(activeForeground(isActive: active))
            .padding(.horizontal, active ? 20 : 14)
            .padding(.vertical, 8)
            .background {
                if active {
                    Capsule(style: .continuous)
                        .fill(activePillFill)
                        .shadow(color: activePillShadow, radius: 6, x: 0, y: 2)
                        .matchedGeometryEffect(id: "activeTabPill", in: glassNamespace)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func activeForeground(isActive: Bool) -> Color {
        if isActive {
            return Color.primary
        }
        return onVibrantCanvas
            ? VersePalette.posterInk.opacity(0.45)
            : Color.secondary
    }

    private var activePillFill: Color {
        Color(uiColor: .systemBackground)
    }

    private var activePillShadow: Color {
        Color.black.opacity(0.12)
    }
}

private extension View {
    @ViewBuilder
    func vibrantCanvasTabTrackGlass(
        glassID: String,
        glassNamespace: Namespace.ID
    ) -> some View {
        if #available(iOS 26.0, *) {
            self
                .background {
                    Capsule(style: .continuous)
                        .fill(Color.white.opacity(0.10))
                }
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(Color.white.opacity(0.24), lineWidth: 0.6)
                }
                .glassEffect(Glass.regular.tint(Color.white.opacity(0.08)).interactive(), in: Capsule())
                .glassEffectID(glassID, in: glassNamespace)
        } else {
            self.background { TopTabBarFallbackTrack() }
        }
    }
}

private struct TopTabBarFallbackTrack: View {
    var body: some View {
        Capsule(style: .continuous)
            .fill(Color.white.opacity(0.18))
            .background {
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(0.62)
            }
            .overlay {
                Capsule(style: .continuous)
                    .strokeBorder(Color.white.opacity(0.28), lineWidth: 0.7)
            }
            .shadow(color: Color.black.opacity(0.035), radius: 12, x: 0, y: 5)
    }
}
