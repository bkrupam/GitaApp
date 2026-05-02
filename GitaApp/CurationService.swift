import Foundation

// MARK: - Protocol

protocol CurationService {
    func verseIDs(forMood mood: Mood) async -> [Int]
    func verseIDs(forFreeText text: String, allVerses: [VerseItem]) async throws -> [Int]
}

// MARK: - Offline implementation

/// Returns the pre-curated IDs embedded in each Mood. Used for the emotion-card path.
final class OfflineCurationService: CurationService {

    func verseIDs(forMood mood: Mood) async -> [Int] {
        mood.verseIDs
    }

    func verseIDs(forFreeText text: String, allVerses: [VerseItem]) async throws -> [Int] {
        keywordMatch(text: text, allVerses: allVerses)
    }
}

// MARK: - Remote implementation (hybrid)

/// Posts the user's free text to a configurable backend endpoint.
/// Falls back to local keyword matching when the request fails or the endpoint is unset.
final class RemoteCurationService: CurationService {

    // Replace with a real URL before shipping the LLM integration.
    private static let endpointURL: URL? = nil

    private struct RemoteResponse: Decodable {
        let verseIDs: [Int]
    }

    func verseIDs(forMood mood: Mood) async -> [Int] {
        mood.verseIDs
    }

    func verseIDs(forFreeText text: String, allVerses: [VerseItem]) async throws -> [Int] {
        guard let url = Self.endpointURL else {
            // No endpoint configured — fall back to local matching.
            return keywordMatch(text: text, allVerses: allVerses)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = try JSONEncoder().encode(["feeling": text])
        request.httpBody = body

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
                return keywordMatch(text: text, allVerses: allVerses)
            }
            let decoded = try JSONDecoder().decode(RemoteResponse.self, from: data)
            return decoded.verseIDs
        } catch {
            // Network or decode error — degrade gracefully to local matching.
            return keywordMatch(text: text, allVerses: allVerses)
        }
    }
}

// MARK: - Shared keyword matching

/// Scores every verse by how many tokens from `text` appear in quote + takeaway.
/// Returns the top 8 verse IDs, or a random 8 if nothing matches.
private func keywordMatch(text: String, allVerses: [VerseItem]) -> [Int] {
    let tokens = text
        .lowercased()
        .components(separatedBy: .whitespacesAndNewlines)
        .filter { $0.count > 3 }   // skip short stop words

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
