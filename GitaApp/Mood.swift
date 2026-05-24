import SwiftUI

// MARK: - Mood model

struct Mood: Identifiable, Hashable {
    let id: String
    let label: String
    let symbol: String       // SF Symbol name (fallback when PNG missing)
    let color: Color         // text & accent — a dark shade of the icon's hue
    let fillColor: Color     // card background — light/soft version of icon's hue
    let tintColor: Color     // extra-pale surface tint (kept for future use)
    let verseIDs: [Int]      // hand-curated verse IDs for this mood

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Mood, rhs: Mood) -> Bool { lhs.id == rhs.id }
}

// MARK: - Catalog
// Colors are derived from each icon's dominant hue so the card background
// and illustration feel like they belong together.

extension Mood {

    static let all: [Mood] = [

        // Rainbow worry doll → warm peachy cream
        Mood(
            id: "anxious",
            label: "Anxious",
            symbol: "wind",
            color:     Color(red: 0.62, green: 0.30, blue: 0.18),
            fillColor: Color(red: 0.99, green: 0.91, blue: 0.84),
            tintColor: Color(red: 1.00, green: 0.96, blue: 0.93),
            verseIDs: [2, 4, 28, 54, 56, 66, 96, 152]
        ),

        // Red broken heart → soft rose
        Mood(
            id: "heartbroken",
            label: "Heartbroken",
            symbol: "heart.slash",
            color:     Color(red: 0.72, green: 0.16, blue: 0.16),
            fillColor: Color(red: 0.99, green: 0.83, blue: 0.83),
            tintColor: Color(red: 1.00, green: 0.94, blue: 0.94),
            verseIDs: [27, 29, 30, 58, 60, 94, 107, 190]
        ),

        // Red-orange character → soft coral
        Mood(
            id: "angry",
            label: "Angry",
            symbol: "flame",
            color:     Color(red: 0.68, green: 0.22, blue: 0.08),
            fillColor: Color(red: 0.99, green: 0.85, blue: 0.75),
            tintColor: Color(red: 1.00, green: 0.95, blue: 0.91),
            verseIDs: [63, 67, 96, 113, 200, 62, 64, 68]
        ),

        // Sandy alien fossil → warm sand
        Mood(
            id: "tired",
            label: "Tired",
            symbol: "moon.zzz",
            color:     Color(red: 0.48, green: 0.36, blue: 0.14),
            fillColor: Color(red: 0.97, green: 0.92, blue: 0.78),
            tintColor: Color(red: 0.99, green: 0.97, blue: 0.92),
            verseIDs: [3, 19, 47, 88, 140, 20, 24, 25]
        ),

        // Grey cloud + figure → light silver-lavender
        Mood(
            id: "overwhelmed",
            label: "Overwhelmed",
            symbol: "cloud.rain",
            color:     Color(red: 0.28, green: 0.32, blue: 0.46),
            fillColor: Color(red: 0.86, green: 0.88, blue: 0.93),
            tintColor: Color(red: 0.94, green: 0.95, blue: 0.97),
            verseIDs: [5, 9, 21, 42, 75, 130, 10, 11]
        ),

        // Gold 3D star → warm golden yellow
        Mood(
            id: "curious",
            label: "Curious",
            symbol: "sparkles",
            color:     Color(red: 0.58, green: 0.40, blue: 0.04),
            fillColor: Color(red: 1.00, green: 0.93, blue: 0.62),
            tintColor: Color(red: 1.00, green: 0.98, blue: 0.88),
            verseIDs: [33, 46, 78, 110, 160, 34, 35, 36]
        ),

        // Orange-yellow sun → warm sunshine
        Mood(
            id: "grateful",
            label: "Grateful",
            symbol: "sun.horizon",
            color:     Color(red: 0.64, green: 0.38, blue: 0.04),
            fillColor: Color(red: 1.00, green: 0.92, blue: 0.62),
            tintColor: Color(red: 1.00, green: 0.97, blue: 0.88),
            verseIDs: [44, 82, 122, 170, 45, 46, 47, 48]
        ),

        // Vivid green leaf → fresh mint
        Mood(
            id: "calm",
            label: "Calm",
            symbol: "leaf",
            color:     Color(red: 0.10, green: 0.48, blue: 0.20),
            fillColor: Color(red: 0.82, green: 0.97, blue: 0.82),
            tintColor: Color(red: 0.93, green: 0.99, blue: 0.93),
            verseIDs: [55, 70, 100, 145, 56, 57, 58, 59]
        ),

        // Crying character (blue jeans, teary) → soft sky blue
        Mood(
            id: "sad",
            label: "Sad",
            symbol: "cloud.drizzle",
            color:     Color(red: 0.18, green: 0.38, blue: 0.68),
            fillColor: Color(red: 0.80, green: 0.91, blue: 0.98),
            tintColor: Color(red: 0.93, green: 0.97, blue: 1.00),
            verseIDs: [27, 30, 45, 83, 125, 175, 28, 29]
        ),

        // Blue infinity loop → pale cornflower
        Mood(
            id: "stuck",
            label: "Stuck",
            symbol: "arrow.triangle.2.circlepath",
            color:     Color(red: 0.18, green: 0.42, blue: 0.76),
            fillColor: Color(red: 0.78, green: 0.90, blue: 0.98),
            tintColor: Color(red: 0.92, green: 0.96, blue: 1.00),
            verseIDs: [1, 6, 22, 38, 72, 118, 185, 7]
        ),

        // Parchment treasure map → warm cream
        Mood(
            id: "lost",
            label: "Lost",
            symbol: "map",
            color:     Color(red: 0.46, green: 0.34, blue: 0.12),
            fillColor: Color(red: 0.98, green: 0.93, blue: 0.76),
            tintColor: Color(red: 0.99, green: 0.97, blue: 0.91),
            verseIDs: [7, 14, 35, 65, 105, 162, 8, 15]
        ),

        // Happy brown monkey → warm caramel cream
        Mood(
            id: "hopeful",
            label: "Hopeful",
            symbol: "star",
            color:     Color(red: 0.44, green: 0.26, blue: 0.10),
            fillColor: Color(red: 0.97, green: 0.90, blue: 0.80),
            tintColor: Color(red: 0.99, green: 0.96, blue: 0.92),
            verseIDs: [50, 90, 135, 195, 51, 52, 91, 136]
        ),
    ]
}
