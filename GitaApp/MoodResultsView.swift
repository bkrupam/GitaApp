import SwiftUI

struct MoodResultsView: View {
    @EnvironmentObject private var gitaVM: GitaViewModel
    @Environment(\.dismiss) private var dismiss
    // nil when results come from free-text (no specific Mood object).
    let mood: Mood?
    let label: String
    let verseIDs: [Int]

    @State private var currentVerseID: Int?
    @Namespace private var resultsChrome

    private let fadeHeight: CGFloat = 48
    private let curatedPalette = VersePalette.curatedResults

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
                                isActive: item.id == currentVerseID,
                                cardPalette: curatedPalette
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
        .gitaVerseCanvasFrost()
        .preferredColorScheme(.light)
        .background {
            VerseBackgroundView(palette: curatedPalette)
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
        GitaChrome.glassEffectGroup(spacing: 12) {
            ZStack {
                moodPill
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                            .symbolRenderingMode(.monochrome)
                            .foregroundStyle(VersePalette.posterInk)
                            .frame(width: 36, height: 36)
                            .gitaHeaderCircleGlass(
                                glassID: "curatedBackOrb",
                                glassNamespace: resultsChrome
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
            .foregroundStyle(VersePalette.posterInk)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .gitaHeaderCapsuleGlass(
                glassID: "curatedMoodPill",
                glassNamespace: resultsChrome
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
                Text("No verses matched — try another mood or phrase")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(VersePalette.posterInkMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            } else {
                Text("\(currentIndex + 1) of \(verses.count)")
                    .font(.system(size: 13, weight: .regular, design: .rounded))
                    .foregroundStyle(VersePalette.posterInkFaint)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: currentIndex)
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
