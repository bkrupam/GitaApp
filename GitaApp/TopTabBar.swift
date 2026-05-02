import SwiftUI

/// Notion-style top pill-bar with two tabs: Verses and Chat.
/// The active tab is highlighted with a capsule background using the shared GitaChrome glass system.
struct TopTabBar: View {
    @Binding var selectedTab: AppTab
    var glassNamespace: Namespace.ID

    var body: some View {
        GitaChrome.glassEffectGroup(spacing: 12) {
            HStack(spacing: 4) {
                tabButton(.verses, icon: "book.pages", label: "Verses")
                tabButton(.chat,   icon: "bubble.left.and.text.bubble.right", label: "Chat")
            }
            .padding(4)
            .gitaHeaderCapsuleGlass(
                glassID: "topTabBarOuter",
                glassNamespace: glassNamespace
            )
        }
    }

    @ViewBuilder
    private func tabButton(_ tab: AppTab, icon: String, label: String) -> some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                selectedTab = tab
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .medium))
                    .symbolRenderingMode(.monochrome)

                if selectedTab == tab {
                    Text(label)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .transition(.opacity.combined(with: .scale(scale: 0.85)))
                }
            }
            .foregroundStyle(selectedTab == tab ? Color.primary : Color.secondary)
            .padding(.horizontal, selectedTab == tab ? 20 : 14)
            .padding(.vertical, 8)
            .background {
                if selectedTab == tab {
                    Capsule(style: .continuous)
                        .fill(Color.primary.opacity(0.08))
                        .matchedGeometryEffect(id: "activeTabPill", in: glassNamespace)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
