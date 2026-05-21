import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var viewModel: GitaViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @Namespace private var homeChrome
    private let fadeHeight: CGFloat = 48
    @State private var showingIndex = false

    var body: some View {
        VStack(spacing: 0) {
            // ── Main scroll area ──────────────────────────────
            GeometryReader { geo in
                let cardH  = geo.size.height * 0.80
                let margin = (geo.size.height - cardH) / 2

                ScrollViewReader { proxy in
                    ScrollView(.vertical, showsIndicators: false) {
                        LazyVStack(spacing: 14) {
                            ForEach(viewModel.verses) { item in
                                CardView(
                                    item: item,
                                    isActive: item.id == viewModel.currentVerseID,
                                    onAskMore: {
                                        let q = "Tell me more about chapter \(item.verse.chapter) verse \(item.verse.verseNumber)"
                                        coordinator.pendingLearnMoreQuery = q
                                        coordinator.pendingLearnMoreVerse = item.verse
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            coordinator.selectedTab = .chat
                                        }
                                    }
                                )
                                .id(item.id)
                                .frame(maxWidth: .infinity)
                                .frame(height: cardH)
                                .padding(.horizontal, 20)
                            }
                        }
                        .scrollTargetLayout()
                    }
                    .contentMargins(.vertical, margin, for: .scrollContent)
                    .scrollTargetBehavior(.viewAligned(limitBehavior: .always))
                    .scrollPosition(id: $viewModel.currentVerseID)
                    .mask(edgeFadeMask)
                    .onChange(of: viewModel.jumpToVerseID) { targetID in
                        guard let id = targetID else { return }
                        viewModel.jumpToVerseID = nil
                        // Keep `currentVerseID` in sync immediately so `isActive` / scale match the
                        // target card. `scrollTo` alone does not reliably update the scrollPosition
                        // binding until the user scrolls again.
                        withAnimation(.easeInOut(duration: 0.65)) {
                            viewModel.currentVerseID = id
                            proxy.scrollTo(id, anchor: .center)
                        }
                    }
                }
            }

            // ── Bottom bar: progress (centre) + chapter menu (trailing) ──
            HStack(alignment: .center) {
                Spacer()

                // Progress label centred
                progressLabel

                Spacer()
            }
            // Room for the floating button on the right without overlapping the label
            .overlay(alignment: .trailing) {
                chapterMenuButton
                    .padding(.trailing, 20)
            }
            .padding(.top, 10)
            .padding(.bottom, 16)
        }
        // ── Full-screen background handled by RootTabView ────────────────────
        // (no local background needed here)
        .sheet(isPresented: $showingIndex) {
            ChapterIndexSheet(isPresented: $showingIndex)
                .environmentObject(viewModel)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(20)
        }
    }

    // MARK: - Floating chapter / verse index button (bottom-right)

    private var chapterMenuButton: some View {
        GitaChrome.glassEffectGroup(spacing: 0) {
            Button {
                showingIndex = true
            } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 20, weight: .medium))
                    .symbolRenderingMode(.monochrome)
                    .foregroundStyle(Color.primary)
                    .frame(width: 48, height: 48)
                    .gitaHeaderCircleGlass(
                        glassID: "homeChapterMenuOrb",
                        glassNamespace: homeChrome
                    )
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Edge fade mask

    private var edgeFadeMask: some View {
        VStack(spacing: 0) {
            LinearGradient(colors: [.clear, .black], startPoint: .top, endPoint: .bottom)
                .frame(height: 22)
            Rectangle().fill(Color.black)
            LinearGradient(colors: [.black, .clear], startPoint: .top, endPoint: .bottom)
                .frame(height: fadeHeight)
        }
    }

    // MARK: - Progress

    private var progressLabel: some View {
        Text("\(viewModel.progressPercent)% completed")
            .font(.system(size: 13, weight: .regular, design: .rounded))
            .foregroundStyle(Color.primary.opacity(0.4))
            .contentTransition(.numericText())
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.progressPercent)
    }
}

#Preview {
    ContentView()
        .environmentObject(GitaViewModel())
}
