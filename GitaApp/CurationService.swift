import Foundation

// MARK: - Protocol

protocol CurationService {
    func verseIDs(forMood mood: Mood) async -> [Int]
    func verseIDs(forFreeText text: String, allVerses: [VerseItem]) async throws -> [Int]
}

// MARK: - Offline implementation

/// Returns the pre-curated IDs embedded in each Mood. Used for the emotion-chip path.
final class OfflineCurationService: CurationService {

    func verseIDs(forMood mood: Mood) async -> [Int] {
        mood.verseIDs
    }

    func verseIDs(forFreeText text: String, allVerses: [VerseItem]) async throws -> [Int] {
        keywordMatch(text: text, allVerses: allVerses)
    }
}

// MARK: - Gemini implementation

/// Uses Gemini when configured; otherwise falls back to local keyword matching.
final class GeminiCurationService: CurationService {
    private let gemini = GeminiClient()
    private let offline = OfflineCurationService()

    func verseIDs(forMood mood: Mood) async -> [Int] {
        await offline.verseIDs(forMood: mood)
    }

    func verseIDs(forFreeText text: String, allVerses: [VerseItem]) async throws -> [Int] {
        if GeminiConfig.isConfigured {
            do {
                let ids = try await gemini.curateVerseIDs(feeling: text, verses: allVerses)
                if !ids.isEmpty { return ids }
            } catch GeminiError.notConfigured {
                // Fall through to keyword match.
            } catch {
                throw error
            }
        }
        return keywordMatch(text: text, allVerses: allVerses)
    }
}

// MARK: - Remote backend implementation (optional)

/// Posts the user's free text to a configurable backend endpoint.
/// Falls back to Gemini or local keyword matching when the endpoint is unset.
final class RemoteCurationService: CurationService {
    private let geminiService = GeminiCurationService()

    // Set this when you add a custom backend (can proxy Gemini server-side).
    private static let endpointURL: URL? = nil

    private struct RemoteResponse: Decodable {
        let verseIDs: [Int]
    }

    func verseIDs(forMood mood: Mood) async -> [Int] {
        await geminiService.verseIDs(forMood: mood)
    }

    func verseIDs(forFreeText text: String, allVerses: [VerseItem]) async throws -> [Int] {
        guard let url = Self.endpointURL else {
            return try await geminiService.verseIDs(forFreeText: text, allVerses: allVerses)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(["feeling": text])

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return try await geminiService.verseIDs(forFreeText: text, allVerses: allVerses)
            }
            let decoded = try JSONDecoder().decode(RemoteResponse.self, from: data)
            let valid = Set(allVerses.map(\.id))
            let filtered = decoded.verseIDs.filter { valid.contains($0) }
            return filtered.isEmpty
                ? try await geminiService.verseIDs(forFreeText: text, allVerses: allVerses)
                : Array(filtered.prefix(8))
        } catch {
            return try await geminiService.verseIDs(forFreeText: text, allVerses: allVerses)
        }
    }
}

// MARK: - Shared keyword matching

/// Scores every verse by how many tokens from `text` appear in quote + takeaway.
/// Returns the top 8 verse IDs, or a random 8 if nothing matches.
func keywordMatch(text: String, allVerses: [VerseItem]) -> [Int] {
    let tokens = text
        .lowercased()
        .components(separatedBy: .whitespacesAndNewlines)
        .filter { $0.count > 3 }

    guard !tokens.isEmpty else {
        return Array(allVerses.shuffled().prefix(8).map(\.id))
    }

    let scored: [(id: Int, score: Int)] = allVerses.map { item in
        let corpus = (item.verse.quote + " " + item.verse.takeaway).lowercased()
        let score = tokens.reduce(0) { $0 + (corpus.contains($1) ? 1 : 0) }
        return (item.id, score)
    }

    let top = scored
        .filter { $0.score > 0 }
        .sorted { $0.score > $1.score }
        .prefix(8)
        .map(\.id)

    return top.isEmpty
        ? Array(allVerses.shuffled().prefix(8).map(\.id))
        : top
}
