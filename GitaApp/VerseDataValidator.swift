import Foundation

enum VerseDataValidator {

    struct Issue: Sendable {
        let message: String
    }

    /// Validates bundled verse JSON and mood references.
    static func validate(verses: [Verse], moods: [Mood] = Mood.all) -> [Issue] {
        var issues: [Issue] = []

        if verses.isEmpty {
            issues.append(Issue(message: "No verses loaded."))
            return issues
        }

        var seenIDs = Set<Int>()
        for verse in verses {
            if verse.id <= 0 {
                issues.append(Issue(message: "Verse id must be positive (got \(verse.id))."))
            }
            if !seenIDs.insert(verse.id).inserted {
                issues.append(Issue(message: "Duplicate verse id \(verse.id)."))
            }
            if verse.chapter < 1 || verse.chapter > 18 {
                issues.append(Issue(message: "Verse \(verse.id) has invalid chapter \(verse.chapter)."))
            }
            if verse.quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(Issue(message: "Verse \(verse.id) is missing quote text."))
            }
            if verse.takeaway.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                issues.append(Issue(message: "Verse \(verse.id) is missing takeaway text."))
            }
        }

        let validIDs = Set(verses.map(\.id))
        for mood in moods {
            let missing = mood.verseIDs.filter { !validIDs.contains($0) }
            if !missing.isEmpty {
                issues.append(
                    Issue(message: "Mood '\(mood.id)' references missing verse IDs: \(missing.map(String.init).joined(separator: ", ")).")
                )
            }
            if mood.verseIDs.count != 8 {
                issues.append(Issue(message: "Mood '\(mood.id)' should have 8 verse IDs (has \(mood.verseIDs.count))."))
            }
        }

        return issues
    }
}
