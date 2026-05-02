import SwiftUI

/// Holds the NavigationStack path so any view can push routes programmatically.
@MainActor
final class NavigationRouter: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ route: AppRoute) {
        path.append(route)
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
