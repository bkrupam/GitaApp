import SwiftUI

/// Root container that shows the top tab bar and switches between Verses and Chat tabs.
/// - Verses tab: full-screen bokeh gradient bleeds under the status bar
/// - Chat tab: always plain white — completely unaffected
struct RootTabView: View {
    @EnvironmentObject private var viewModel: GitaViewModel
    @EnvironmentObject private var router: NavigationRouter
    @EnvironmentObject private var coordinator: AppCoordinator
    @Namespace private var tabBarNamespace

    private var activePalette: VersePalette {
        viewModel.currentVerse?.palette ?? VersePalette.all[0]
    }

    /// Drive dark/light glass on the tab bar depending on which tab is active
    private var tabBarScheme: ColorScheme {
        coordinator.selectedTab == .verses ? .dark : .light
    }

    var body: some View {
        VStack(spacing: 0) {
            TopTabBar(selectedTab: $coordinator.selectedTab, glassNamespace: tabBarNamespace)
                .padding(.top, 12)
                .padding(.bottom, 8)
                // Tab bar glass adapts: dark over gradient, light over white
                .environment(\.colorScheme, tabBarScheme)

            Group {
                switch coordinator.selectedTab {
                case .verses:
                    ContentView()
                        .transition(.opacity)
                case .chat:
                    ChatView()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.2), value: coordinator.selectedTab)
        }
        .background {
            if coordinator.selectedTab == .verses {
                // Bokeh gradient covers the full screen including status bar
                VerseBackgroundView(palette: activePalette)
                    .id(activePalette.id)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.75), value: activePalette.id)
                    .ignoresSafeArea()
            } else {
                // Chat tab: pure white, always
                Color.white.ignoresSafeArea()
            }
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

#Preview {
    let coordinator = AppCoordinator()
    NavigationStack {
        RootTabView()
            .environmentObject(GitaViewModel())
            .environmentObject(NavigationRouter())
            .environmentObject(coordinator)
            .environmentObject(coordinator.chatViewModel)
    }
}
