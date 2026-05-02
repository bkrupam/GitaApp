import Foundation

struct Verse: Identifiable, Codable {
    let id: Int
    let chapter: Int
    /// Display label — "1", "21-22", etc.
    let verseNumber: String
    /// Side A — the punchy modern hook shown on the card front
    let quote: String
    /// Transliterated Sanskrit shlok
    let shlok: String
    /// What is literally happening in the scene
    let scene: String
    /// The deeper insight / takeaway
    let takeaway: String
}
