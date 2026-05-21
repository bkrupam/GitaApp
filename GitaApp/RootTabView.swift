import SwiftUI

/// Root container — tab bar stacked above the full-screen scroll content.
/// The background gradient bleeds behind the status bar via ignoresSafeArea.
struct RootTabView: View {
    @EnvironmentObject private var viewModel: GitaViewModel
    @EnvironmentObject private var router: NavigationRouter
    @EnvironmentObject private var coordinator: AppCoordinator
    @Namespace private var tabBarNamespace

    private var activePalette: VersePalette {
        viewModel.currentVerse?.palette ?? VersePalette.all[0]
    }

    var body: some View {
        VStack(spacing: 0) {
            TopTabBar(selectedTab: $coordinator.selectedTab, glassNamespace: tabBarNamespace)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .environment(\.colorScheme, .light)

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
                VerseBackgroundView(palette: activePalette)
                    .id("verse-bg-\(activePalette.id)")
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 1.0), value: activePalette.id)
                    .ignoresSafeArea()
            } else {
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
