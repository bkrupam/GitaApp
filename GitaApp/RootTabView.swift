import SwiftUI

/// Root container that shows the top tab bar and switches between Verses and Chat tabs.
/// Deep navigation (MoodResultsView, freeTextResults) still uses the NavigationStack in GitaAppApp.
struct RootTabView: View {
    @EnvironmentObject private var viewModel: GitaViewModel
    @EnvironmentObject private var router: NavigationRouter
    @EnvironmentObject private var coordinator: AppCoordinator
    @Namespace private var tabBarNamespace

    var body: some View {
        VStack(spacing: 0) {
            // ── Top tab bar ───────────────────────────────────
            TopTabBar(selectedTab: $coordinator.selectedTab, glassNamespace: tabBarNamespace)
                .padding(.top, 12)
                .padding(.bottom, 8)

            // ── Tab content ───────────────────────────────────
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
        .background(Color.white)
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
