import SwiftUI

struct ChapterIndexSheet: View {
    @EnvironmentObject private var viewModel: GitaViewModel
    @Binding var isPresented: Bool

    private var grouped: [Int: [VerseItem]] {
        Dictionary(grouping: viewModel.verses, by: { $0.verse.chapter })
    }
    private var sortedChapters: [Int] { grouped.keys.sorted() }

    var body: some View {
        VStack(spacing: 0) {
            sheetHeader
            Divider()
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(sortedChapters.enumerated()), id: \.element) { index, chapter in
                            chapterRow(chapter)
                            Divider()
                        }
                    }
                }
                .onAppear {
                    if let ch = viewModel.currentVerse?.verse.chapter {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            withAnimation { proxy.scrollTo(ch, anchor: .top) }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Header

    private var sheetHeader: some View {
        HStack(alignment: .center, spacing: 16) {
            // Portrait book cover
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(Color.orange.opacity(0.15))
                .frame(width: 44, height: 58)
                .overlay(
                    Image(systemName: "book.closed.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(.orange)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Bhagavad Gita")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.primary)
                Text("\(sortedChapters.count) chapters")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            dismissButton
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 20)
    }

    @ViewBuilder
    private var dismissButton: some View {
        if #available(iOS 26, *) {
            Button { isPresented = false } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
            .glassEffect(in: .circle)
        } else {
            Button { isPresented = false } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Chapter row

    @ViewBuilder
    private func chapterRow(_ chapter: Int) -> some View {
        let verses = grouped[chapter] ?? []
        let isCurrent = viewModel.currentVerse?.verse.chapter == chapter

        Button {
            guard let first = verses.first else { return }
            viewModel.jumpToVerseID = first.id
            isPresented = false
        } label: {
            HStack {
                Text("Chapter \(chapter)")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(isCurrent ? .primary : .primary)
                Spacer()
                Text("\(verses.count) verses")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .id(chapter)
    }
}
