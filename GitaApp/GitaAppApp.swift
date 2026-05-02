import SwiftUI

@main
struct GitaAppApp: App {
    @StateObject private var gitaVM = GitaViewModel()
    @StateObject private var router = NavigationRouter()
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                RootTabView()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .moodResults(let mood, let ids):
                            MoodResultsView(
                                mood: mood,
                                label: "For when you feel \(mood.label)",
                                verseIDs: ids
                            )
                        case .freeTextResults(let title, let ids):
                            MoodResultsView(
                                mood: nil,
                                label: title,
                                verseIDs: ids
                            )
                        }
                    }
            }
            .environmentObject(gitaVM)
            .environmentObject(router)
            .environmentObject(coordinator)
            .environmentObject(coordinator.chatViewModel)
            .preferredColorScheme(.light)
        }
    }
}

