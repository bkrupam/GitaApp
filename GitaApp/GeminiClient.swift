import Foundation

enum GeminiError: LocalizedError {
    case notConfigured
    case invalidResponse
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Gemini API key is not configured. Add GeminiSecrets.plist or set GEMINI_API_KEY."
        case .invalidResponse:
            return "The model returned an unexpected response."
        case .apiError(let message):
            return message
        }
    }
}

/// Minimal Gemini REST client for verse curation and learn-more replies.
final class GeminiClient: Sendable {

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func generateText(prompt: String) async throws -> String {
        guard let apiKey = GeminiConfig.apiKey else {
            throw GeminiError.notConfigured
        }

        var components = URLComponents(string: "https://generativelanguage.googleapis.com/v1beta/models/\(GeminiConfig.modelName):generateContent")!
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]

        guard let url = components.url else {
            throw GeminiError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(GenerateRequest(
            contents: [Content(parts: [Part(text: prompt)])],
            generationConfig: GenerationConfig(temperature: 0.7, maxOutputTokens: 1024)
        ))

        let (data, response) = try await session.data(for: request)

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            let body = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw GeminiError.apiError("Gemini request failed (\(http.statusCode)): \(body)")
        }

        let decoded = try JSONDecoder().decode(GenerateResponse.self, from: data)
        guard let text = decoded.candidates?.first?.content.parts.first?.text,
              !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw GeminiError.invalidResponse
        }
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns up to 8 verse IDs from the bundled catalog for the user's feeling.
    func curateVerseIDs(feeling: String, verses: [VerseItem]) async throws -> [Int] {
        let catalog = verses.map { item in
            """
            id=\(item.id) ch=\(item.verse.chapter) v=\(item.verse.verseNumber)
            quote: \(item.verse.quote)
            takeaway: \(item.verse.takeaway)
            """
        }.joined(separator: "\n\n")

        let prompt = """
        You are curating Bhagavad Gita verse cards for a user who feels: "\(feeling)".

        Choose exactly 8 verse IDs from the catalog below that best match their emotional state.
        Return ONLY valid JSON in this exact shape, with no markdown fences:
        {"verseIDs":[1,2,3,4,5,6,7,8]}

        Rules:
        - Use only IDs that appear in the catalog.
        - Prefer emotionally resonant matches over literal keyword matches.
        - Do not repeat IDs.

        Catalog:
        \(catalog)
        """

        let raw = try await generateText(prompt: prompt)
        return try parseVerseIDs(from: raw, validIDs: Set(verses.map(\.id)))
    }

    func learnMore(verse: Verse, userQuery: String) async throws -> String {
        let prompt = """
        You are a warm, concise guide to the Bhagavad Gita. The user tapped "Learn more" on one verse.

        User question: \(userQuery)

        Verse context:
        - Chapter \(verse.chapter), verse \(verse.verseNumber)
        - Quote: \(verse.quote)
        - Shlok: \(verse.shlok)
        - Scene: \(verse.scene)
        - Takeaway: \(verse.takeaway)

        Write 2-4 short paragraphs in plain English. Be specific to this verse, not generic.
        No bullet lists. No markdown headings. Do not invent facts outside the provided context.
        """

        return try await generateText(prompt: prompt)
    }

    private func parseVerseIDs(from raw: String, validIDs: Set<Int>) throws -> [Int] {
        let trimmed = raw
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard let data = trimmed.data(using: .utf8) else {
            throw GeminiError.invalidResponse
        }

        struct Payload: Decodable { let verseIDs: [Int] }

        if let payload = try? JSONDecoder().decode(Payload.self, from: data) {
            let filtered = Array(payload.verseIDs.filter { validIDs.contains($0) }.prefix(8))
            if !filtered.isEmpty { return filtered }
        }

        // Fallback: extract integers from a loose JSON-like response.
        let numbers = trimmed
            .components(separatedBy: CharacterSet.decimalDigits.inverted)
            .compactMap { Int($0) }
            .filter { validIDs.contains($0) }

        var seen = Set<Int>()
        var unique: [Int] = []
        for n in numbers where validIDs.contains(n) {
            if seen.insert(n).inserted {
                unique.append(n)
            }
            if unique.count == 8 { break }
        }
        guard !unique.isEmpty else { throw GeminiError.invalidResponse }
        return unique
    }
}

// MARK: - API models

private struct GenerateRequest: Encodable {
    let contents: [Content]
    let generationConfig: GenerationConfig
}

private struct Content: Encodable {
    let parts: [Part]
}

private struct Part: Encodable {
    let text: String
}

private struct GenerationConfig: Encodable {
    let temperature: Double
    let maxOutputTokens: Int
}

private struct GenerateResponse: Decodable {
    let candidates: [Candidate]?
}

private struct Candidate: Decodable {
    let content: ResponseContent
}

private struct ResponseContent: Decodable {
    let parts: [ResponsePart]
}

private struct ResponsePart: Decodable {
    let text: String?
}
