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

struct ChatFreeTextResponse: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let verseIDs: [Int]

    var assistantText: String {
        "Here are \(verseIDs.count) verses that may help"
    }

    var cardTitle: String { "View cards" }

    var subtitle: String { "Curated for what you shared" }
}

enum ChatMessage: Identifiable, Equatable {
    case userMood(id: UUID = UUID(), mood: Mood)
    case userText(id: UUID = UUID(), text: String)
    case assistantText(id: UUID = UUID(), fullText: String)
    case assistantCards(id: UUID = UUID(), response: ChatMoodResponse)
    case assistantFreeTextCards(id: UUID = UUID(), response: ChatFreeTextResponse)

    var id: UUID {
        switch self {
        case .userMood(let id, _), .userText(let id, _),
             .assistantText(let id, _), .assistantCards(let id, _),
             .assistantFreeTextCards(let id, _):
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
    private let gemini = GeminiClient()

    init(service: CurationService = GeminiCurationService()) {
        self.service = service
    }

    var canSubmit: Bool {
        !freeText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var hasStartedConversation: Bool {
        !messages.isEmpty || isAwaitingMoodResponse || isLoading
    }

    /// Free-text flow: user bubble → thinking → assistant intro → card CTA (same pattern as mood).
    func handleFreeTextSubmit(allVerses: [VerseItem]) async {
        let trimmed = freeText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isLoading, !isAwaitingMoodResponse else { return }

        messages.append(.userText(text: trimmed))
        freeText = ""
        isLoading = true
        errorMessage = nil

        do {
            let ids = try await service.verseIDs(forFreeText: trimmed, allVerses: allVerses)
            guard !ids.isEmpty else {
                errorMessage = "I couldn't find verses for that yet. Try describing how you feel in a few words."
                isLoading = false
                return
            }

            let response = ChatFreeTextResponse(title: "Curated for you", verseIDs: ids)
            messages.append(.assistantText(fullText: response.assistantText))
            messages.append(.assistantFreeTextCards(response: response))
        } catch {
            errorMessage = friendlyErrorMessage(for: error)
        }

        isLoading = false
    }

    func verseIDs(forMood mood: Mood) async -> [Int] {
        await service.verseIDs(forMood: mood)
    }

    func handleMoodSelection(_ mood: Mood) async {
        guard !isAwaitingMoodResponse && !isLoading else { return }

        messages.append(.userMood(mood: mood))
        isAwaitingMoodResponse = true
        errorMessage = nil

        let ids = await service.verseIDs(forMood: mood)
        let response = ChatMoodResponse(mood: mood, verseIDs: ids)
        messages.append(.assistantText(fullText: response.assistantText))
        messages.append(.assistantCards(response: response))
        isAwaitingMoodResponse = false
    }

    /// Handles "Learn more" from a card back with full verse context when available.
    func handleLearnMore(query: String, verse: Verse?) async {
        guard !isAwaitingMoodResponse && !isLoading else { return }

        messages.append(.userText(text: query))
        isAwaitingMoodResponse = true
        errorMessage = nil

        let reply: String
        if let verse, GeminiConfig.isConfigured {
            do {
                reply = try await gemini.learnMore(verse: verse, userQuery: query)
            } catch {
                errorMessage = friendlyErrorMessage(for: error)
                reply = offlineLearnMoreFallback(verse: verse)
            }
        } else if let verse {
            reply = offlineLearnMoreFallback(verse: verse)
        } else {
            reply = offlineLearnMoreFallback(verse: nil)
        }

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

    private func offlineLearnMoreFallback(verse: Verse?) -> String {
        if let verse {
            return """
            On chapter \(verse.chapter), verse \(verse.verseNumber): \(verse.takeaway)

            Sit with this teaching for a moment. The Gita often reveals more when you return to a verse with a quieter mind than when you first read it.
            """
        }
        return """
        The Gita's wisdom runs deeper than it first appears. Each verse is a doorway — the more still you become, the further in it takes you.
        """
    }

    private func friendlyErrorMessage(for error: Error) -> String {
        if let gemini = error as? GeminiError {
            switch gemini {
            case .notConfigured:
                return "AI isn't set up yet. Add your Gemini API key in GeminiSecrets.plist to enable Learn more and smarter curation."
            case .invalidResponse:
                return "I had trouble understanding the response. Please try again."
            case .apiError(let message):
                if message.contains("429") {
                    return "The AI service is busy. Please wait a moment and try again."
                }
                return "Something went wrong connecting to AI. You can still browse verses in the Verses tab."
            }
        }
        return "Something went wrong. Please try again."
    }
}
