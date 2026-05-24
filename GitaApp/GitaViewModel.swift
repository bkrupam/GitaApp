import SwiftUI
import Combine

// MARK: - VerseItem

/// A verse paired with its pre-assigned background palette index.
struct VerseItem: Identifiable {
    let id: Int
    let verse: Verse
    let paletteID: Int

    var palette: VersePalette { VersePalette.all[paletteID] }
    // Legacy shims so other views don't need simultaneous changes
    var color: Color { .white }
    var tintColor: Color { .white.opacity(0.15) }
}

// MARK: - GitaViewModel

@MainActor
final class GitaViewModel: ObservableObject {

    @Published var verses: [VerseItem] = []
    @Published var currentVerseID: Int?
    /// Set this to trigger a smooth animated scroll to a specific verse.
    @Published var jumpToVerseID: Int?

    private static let paletteCount = VersePalette.all.count

    // MARK: Computed helpers

    var currentVerse: VerseItem? {
        guard let id = currentVerseID else { return verses.first }
        return verses.first { $0.id == id }
    }

    var currentIndex: Int {
        guard let id = currentVerseID else { return 0 }
        return verses.firstIndex { $0.id == id } ?? 0
    }

    var progressPercent: Int {
        guard !verses.isEmpty else { return 0 }
        return Int(Double(currentIndex + 1) / Double(verses.count) * 100)
    }

    // MARK: Init

    init() {
        loadVerses()
    }

    // MARK: Private

    private func loadVerses() {
        guard
            let url = Bundle.main.url(forResource: "verses", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([Verse].self, from: data)
        else {
            return
        }

        // Map each verse to its chapter's palette (chapter 1 → id 0, etc.)
        // Clamp to available palette count so adding more chapters never crashes.
        verses = decoded.map { verse in
            let idx = min(verse.chapter - 1, Self.paletteCount - 1)
            return VerseItem(id: verse.id, verse: verse, paletteID: max(0, idx))
        }

        let issues = VerseDataValidator.validate(verses: decoded)
        #if DEBUG
        if !issues.isEmpty {
            for issue in issues {
                print("⚠️ Verse data: \(issue.message)")
            }
        }
        #endif

        currentVerseID = verses.first?.id
    }
}
