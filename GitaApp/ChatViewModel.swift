import SwiftUI
import Combine

// MARK: - Route types for typed NavigationStack navigation

enum AppRoute: Hashable {
    case moodResults(mood: Mood, verseIDs: [Int])
    case freeTextResults(title: String, verseIDs: [Int])
}

// MARK: - Top-level tab

enum AppTab: String, CaseIterable {
    case verses
    case chat
}

struct ChatMoodResponse: Identifiable, Equatable {
    let id = UUID()
    let mood: Mood
    let verseIDs: [Int]

    var assistantText: String {
        "Here are \(verseIDs.count) cards for you"
    }

    var cardTitle: String {
        "View cards"
    }

    var generatedCountText: String {
        "\(verseIDs.count) cards generated"
    }

    var subtitle: String {
        "To make you feel \(mood.label.lowercased())"
    }
}

enum ChatMessage: Identifiable, Equatable {
    case userMood(id: UUID = UUID(), mood: Mood)
    case userText(id: UUID = UUID(), text: String)
    case assistantText(id: UUID = UUID(), fullText: String)
    case assistantCards(id: UUID = UUID(), response: ChatMoodResponse)

    var id: UUID {
        switch self {
        case .userMood(let id, _), .userText(let id, _),
             .assistantText(let id, _), .assistantCards(let id, _):
            return id
        }
    }
}

// MARK: - ChatViewModel

@MainActor
final class ChatViewModel: ObservableObject {

    @Published var freeText: String = ""
    @Published var isLoading: Bool = false
    @Published var isAwaitingMoodResponse: Bool = false
    @Published var errorMessage: String? = nil
    @Published var messages: [ChatMessage] = []

    private let service: CurationService

    init(service: CurationService = RemoteCurationService()) {
        self.service = service
    }

    var canSubmit: Bool {
        !freeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var hasStartedConversation: Bool {
        !messages.isEmpty || isAwaitingMoodResponse
    }

    /// Returns curated verse IDs for the typed free-text, or nil on error.
    func submitFreeText(allVerses: [VerseItem]) async -> [Int]? {
        let trimmed = freeText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        isLoading = true
        errorMessage = nil

        do {
            let ids = try await service.verseIDs(forFreeText: trimmed, allVerses: allVerses)
            isLoading = false
            return ids.isEmpty ? nil : ids
        } catch {
            isLoading = false
            errorMessage = "Something went wrong. Please try again."
            return nil
        }
    }

    /// Returns curated verse IDs for a selected mood tile (always offline, always succeeds).
    func verseIDs(forMood mood: Mood) async -> [Int] {
        await service.verseIDs(forMood: mood)
    }

    func handleMoodSelection(_ mood: Mood) async {
        guard !isAwaitingMoodResponse && !isLoading else { return }

        messages.append(.userMood(mood: mood))
        isAwaitingMoodResponse = true
        errorMessage = nil

        let ids = await service.verseIDs(forMood: mood)

        try? await Task.sleep(for: .milliseconds(2400))

        let response = ChatMoodResponse(mood: mood, verseIDs: ids)
        messages.append(.assistantText(fullText: response.assistantText))
        messages.append(.assistantCards(response: response))
        isAwaitingMoodResponse = false
    }

    /// Handles "Learn more" from a card back, or a chip tap.
    /// Adds a user text bubble, shows a thinking indicator, then appends a placeholder reply.
    func handleLearnMore(query: String) async {
        guard !isAwaitingMoodResponse && !isLoading else { return }

        messages.append(.userText(text: query))
        isAwaitingMoodResponse = true

        try? await Task.sleep(for: .milliseconds(1600))

        let reply = "The Gita's wisdom on this runs deeper than it first appears. Each verse is a doorway — the more still you become, the further in it takes you. Sit with this teaching and let it reveal new layers each time you return to it."
        messages.append(.assistantText(fullText: reply))
        isAwaitingMoodResponse = false
    }

    func resetChat() {
        freeText = ""
        isLoading = false
        isAwaitingMoodResponse = false
        errorMessage = nil
        messages = []
    }

    func clearError() { errorMessage = nil }
}
