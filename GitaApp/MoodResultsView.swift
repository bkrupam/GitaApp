import SwiftUI

struct MoodResultsView: View {
    @EnvironmentObject private var gitaVM: GitaViewModel
    @Environment(\.dismiss) private var dismiss
    @Namespace private var resultsHeaderChrome
    @Namespace private var resultsProgressChrome

    // nil when results come from free-text (no specific Mood object).
    let mood: Mood?
    let label: String
    let verseIDs: [Int]

    @State private var currentVerseID: Int?

    private let fadeHeight: CGFloat = 48

    // Filtered + ordered subset of the full verse list.
    private var verses: [VerseItem] {
        let idSet = Set(verseIDs)
        let matched = gitaVM.verses.filter { idSet.contains($0.id) }
        let lookup = Dictionary(uniqueKeysWithValues: matched.map { ($0.id, $0) })
        return verseIDs.compactMap { lookup[$0] }
    }

    private var currentIndex: Int {
        guard let id = currentVerseID else { return 0 }
        return verses.firstIndex { $0.id == id } ?? 0
    }

    // Derives a medium-saturation gradient top colour from the mood's colour pair.
    // Blends 35% from fillColor toward the darker accent color so the result is
    // clearly tinted but never heavy.
    private var gradientTopColor: Color {
        guard let m = mood else {
            return Color(red: 0.55, green: 0.68, blue: 0.90) // neutral blue for free-text
        }
        let c = UIColor(m.color)
        let f = UIColor(m.fillColor)
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        c.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        f.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
        let t: CGFloat = 0.35
        return Color(red: r2 * (1 - t) + r1 * t,
                     green: g2 * (1 - t) + g1 * t,
                     blue: b2 * (1 - t) + b1 * t)
    }

    private var gradientMidColor: Color {
        mood?.fillColor ?? Color(red: 0.84, green: 0.90, blue: 0.97)
    }

    var body: some View {
        VStack(spacing: 0) {
            headerRow
                .padding(.top, 12)
                .padding(.bottom, 10)

            GeometryReader { geo in
                let cardH  = geo.size.height * 0.80
                let margin = (geo.size.height - cardH) / 2

                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 14) {
                        ForEach(verses) { item in
                            CardView(
                                item: item,
                                isActive: item.id == currentVerseID
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: cardH)
                            .padding(.horizontal, 20)
                        }
                    }
                    .scrollTargetLayout()
                }
                .contentMargins(.vertical, margin, for: .scrollContent)
                .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                .scrollPosition(id: $currentVerseID)
                .mask(edgeFadeMask)
            }

            progressLabel
                .padding(.top, 10)
                .padding(.bottom, 16)
        }
        .background {
            ZStack {
                let b  = VersePalette.base
                let c1 = gradientTopColor
                let c2 = gradientMidColor
                MeshGradient(
                    width: 3,
                    height: 3,
                    points: [
                        [0, 0], [0.5, 0], [1, 0],
                        [0, 0.5], [0.5, 0.5], [1, 0.5],
                        [0, 1], [0.5, 1], [1, 1]
                    ],
                    colors: [
                        c1,                        // top-left
                        c1.mix(with: b, by: 0.35), // top-center
                        b,                         // top-right
                        c1.mix(with: b, by: 0.35), // mid-left
                        b,                         // center
                        c2.mix(with: b, by: 0.35), // mid-right
                        b,                         // bottom-left
                        c2.mix(with: b, by: 0.35), // bottom-center
                        c2,                        // bottom-right
                    ],
                    background: VersePalette.base
                )
                .ignoresSafeArea()
                GrainOverlay(opacity: 0.06)
            }
            .ignoresSafeArea()
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            if currentVerseID == nil {
                currentVerseID = verses.first?.id
            }
        }
    }

    // MARK: - Header row

    private var headerRow: some View {
        GitaChrome.glassEffectGroup(spacing: 20) {
            ZStack {
                moodPill
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(.primary)
                            .frame(width: 36, height: 36)
                            .gitaHeaderCircleGlass(
                                glassID: "resultsBackOrb",
                                glassNamespace: resultsHeaderChrome
                            )
                    }
                    .buttonStyle(.plain)
                    Spacer()
                }
                .padding(.horizontal, 20)
            }
        }
    }

    private var moodPill: some View {
        Text(label)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundStyle(.primary)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .gitaHeaderCapsuleGlass(
                glassID: "resultsTitleCapsule",
                glassNamespace: resultsHeaderChrome
            )
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: label)
            .accessibilityLabel(
                mood.map { "Curated verses for when you feel \($0.label)" } ?? label
            )
    }

    // MARK: - Edge fade mask

    private var edgeFadeMask: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                .frame(height: fadeHeight)
            Rectangle().fill(Color.black)
            LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: fadeHeight)
        }
    }

    // MARK: - Progress label

    private var progressLabel: some View {
        Group {
            if verses.isEmpty {
                Text("")
            } else {
                Text("\(currentIndex + 1) of \(verses.count)")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentIndex)
                    .gitaProgressCaptionGlass(
                        glassID: "resultsProgressChip",
                        glassNamespace: resultsProgressChrome
                    )
            }
        }
    }
}

#Preview {
    NavigationStack {
        MoodResultsView(
            mood: Mood.all[0],
            label: "For when you feel Anxious",
            verseIDs: [1, 2, 3, 4, 5]
        )
        .environmentObject(GitaViewModel())
    }
}
