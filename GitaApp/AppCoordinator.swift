import SwiftUI

/// Shared coordinator that drives tab selection and passes "Learn more" queries from the
/// Verses tab into the Chat tab without tight coupling between the two screens.
@MainActor
final class AppCoordinator: ObservableObject {
    @Published var selectedTab: AppTab = .verses

    /// Set this before switching to .chat — ChatView consumes it on appear / change.
    @Published var pendingLearnMoreQuery: String? = nil
    @Published var pendingLearnMoreVerse: Verse? = nil

    /// Owned here so it survives tab switches (ChatView uses it as @EnvironmentObject).
    let chatViewModel = ChatViewModel()
}
