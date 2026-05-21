import Foundation

/// Reads Gemini credentials for local development.
/// Copy `GeminiSecrets.plist.example` to `GeminiSecrets.plist` and add your API key.
enum GeminiConfig {
    private static let secretsFileName = "GeminiSecrets"
    private static let apiKeyKey = "GEMINI_API_KEY"

    static var apiKey: String? {
        if let env = ProcessInfo.processInfo.environment[apiKeyKey],
           !env.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return env
        }

        guard
            let url = Bundle.main.url(forResource: secretsFileName, withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
            let key = plist[apiKeyKey] as? String
        else {
            return nil
        }

        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, trimmed != "YOUR_GEMINI_API_KEY_HERE" else { return nil }
        return trimmed
    }

    static var isConfigured: Bool { apiKey != nil }

    static let modelName = "gemini-2.0-flash"
}
