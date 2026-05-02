import SwiftUI
import Combine

// MARK: - VerseItem

/// A verse paired with its pre-assigned VIBGYOR color.
struct VerseItem: Identifiable {
    let id: Int
    let verse: Verse
    let color: Color
    let tintColor: Color  // lighter pastel tint for card background
}

// MARK: - GitaViewModel

@MainActor
final class GitaViewModel: ObservableObject {

    @Published var verses: [VerseItem] = []
    @Published var currentVerseID: Int?
    /// Set this to trigger a smooth animated scroll to a specific verse.
    @Published var jumpToVerseID: Int?

    // MARK: VIBGYOR palette
    private static let palette: [(main: Color, tint: Color)] = [
        (Color(red: 0.580, green: 0.310, blue: 0.980), Color(red: 0.960, green: 0.940, blue: 1.000)), // Violet
        (Color(red: 0.380, green: 0.400, blue: 0.950), Color(red: 0.940, green: 0.945, blue: 1.000)), // Indigo
        (Color(red: 0.200, green: 0.500, blue: 0.980), Color(red: 0.930, green: 0.950, blue: 1.000)), // Blue
        (Color(red: 0.110, green: 0.760, blue: 0.370), Color(red: 0.920, green: 1.000, blue: 0.945)), // Green
        (Color(red: 0.940, green: 0.720, blue: 0.020), Color(red: 1.000, green: 0.985, blue: 0.910)), // Yellow
        (Color(red: 0.980, green: 0.450, blue: 0.080), Color(red: 1.000, green: 0.955, blue: 0.930)), // Orange
        (Color(red: 0.940, green: 0.260, blue: 0.260), Color(red: 1.000, green: 0.940, blue: 0.940)), // Red
    ]

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

        var lastPaletteIndex: Int? = nil
        verses = decoded.map { verse in
            var idx: Int
            repeat {
                idx = Int.random(in: 0..<Self.palette.count)
            } while idx == lastPaletteIndex
            lastPaletteIndex = idx

            let entry = Self.palette[idx]
            return VerseItem(id: verse.id, verse: verse, color: entry.main, tintColor: entry.tint)
        }

        currentVerseID = verses.first?.id
    }
}
