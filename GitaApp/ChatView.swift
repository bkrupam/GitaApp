import SwiftUI

private struct TypewriterTextBubble: View {
    let text: String

    @State private var displayedText = ""

    var body: some View {
        HStack {
            Text(displayedText)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.primary)
                .lineSpacing(5)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .onAppear {
                    guard displayedText.isEmpty else { return }
                    Task {
                        await typeText()
                    }
                }

            Spacer(minLength: 32)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func typeText() async {
        for character in text {
            displayedText.append(character)
            try? await Task.sleep(for: .milliseconds(28))
        }
    }
}

struct ChatView: View {
    @EnvironmentObject private var gitaVM: GitaViewModel
    @EnvironmentObject private var router: NavigationRouter
    @EnvironmentObject private var vm: ChatViewModel
    @EnvironmentObject private var coordinator: AppCoordinator
    @Namespace private var chatComposerChrome
    @Namespace private var responseCardChrome

    @State private var showingNewChatConfirmation = false

    private let row1Moods = Array(Mood.all.prefix(7))
    private let row2Moods = Array(Mood.all.suffix(6))

    var body: some View {
        VStack(spacing: 0) {
            chatFeedSection

            if !vm.hasStartedConversation {
                // ── Row 1: right → left ────────────────────────────
                AutoScrollChipRow(
                    moods: row1Moods,
                    direction: -1,
                    onTap: handleMoodTap,
                    isDisabled: vm.isAwaitingMoodResponse || vm.isLoading
                )
                .padding(.bottom, 10)

                // ── Row 2: left → right ────────────────────────────
                AutoScrollChipRow(
                    moods: row2Moods,
                    direction: 1,
                    onTap: handleMoodTap,
                    isDisabled: vm.isAwaitingMoodResponse || vm.isLoading
                )
                .padding(.bottom, 36)

                Spacer()
            }

            // ── Bottom composer bar ───────────────────────────
            composerBar
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                .padding(.top, 8)
        }
        .alert("Couldn't find verses", isPresented: .init(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.clearError() } }
        )) {
            Button("OK") { vm.clearError() }
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .alert("Start a new chat?", isPresented: $showingNewChatConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Yes", role: .destructive) {
                vm.resetChat()
            }
        } message: {
            Text("Existing progress will get lost.")
        }
        .onAppear { consumePendingQuery() }
        .onChange(of: coordinator.pendingLearnMoreQuery) { _ in consumePendingQuery() }
    }

    private func consumePendingQuery() {
        guard let q = coordinator.pendingLearnMoreQuery else { return }
        let verse = coordinator.pendingLearnMoreVerse
        coordinator.pendingLearnMoreQuery = nil
        coordinator.pendingLearnMoreVerse = nil
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            vm.resetChat()
            await vm.handleLearnMore(query: q, verse: verse)
        }
    }

    private var chatFeedSection: some View {
        ScrollViewReader { proxy in
            Group {
                if !vm.hasStartedConversation {
                    VStack {
                        Spacer()
                        greetingSection
                        Spacer()
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 18) {
                            VStack(spacing: 20) {
                                ForEach(vm.messages) { message in
                                    messageRow(message)
                                        .id(message.id)
                                }

                                if vm.isAwaitingMoodResponse || vm.isLoading {
                                    thinkingRow
                                        .id("thinking")
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 28)
                        }
                    }
                    .onChange(of: vm.messages.count) { messageCount in
                        scrollToLatest(proxy)
                    }
                    .onChange(of: vm.isAwaitingMoodResponse) { _ in scrollToLatest(proxy) }
                    .onChange(of: vm.isLoading) { _ in scrollToLatest(proxy) }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    // MARK: - Greeting

    private var greetingSection: some View {
        VStack(spacing: 14) {
            Text("☸")
                .font(.system(size: 40))

            Text("How can the Gita\nhelp you today?")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
    }


    // MARK: - Composer bar

    private var composerBar: some View {
        GitaChrome.glassEffectGroup(spacing: 12) {
            HStack(spacing: 10) {
                Button {
                    showingNewChatConfirmation = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(.primary)
                        .frame(width: 40, height: 40)
                        .gitaHeaderCircleGlass(
                            glassID: "chatNewConversationOrb",
                            glassNamespace: chatComposerChrome
                        )
                }
                .buttonStyle(.plain)

                TextField("Tell me how you're feeling…", text: $vm.freeText, axis: .vertical)
                    .lineLimit(1...3)
                    .font(.system(size: 15, design: .rounded))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .gitaInputFieldGlass(
                        cornerRadius: 20,
                        glassID: "chatComposerField",
                        glassNamespace: chatComposerChrome
                    )
                    .submitLabel(.send)
                    .onSubmit { handleSubmit() }

                Button { handleSubmit() } label: {
                    Image(systemName: "arrow.up")
                        .font(.system(size: 16, weight: .semibold))
                        .symbolRenderingMode(.monochrome)
                        .foregroundStyle(
                            vm.canSubmit && !vm.isLoading
                                ? Color.white
                                : Color.secondary.opacity(0.45)
                        )
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(
                                    vm.canSubmit && !vm.isLoading
                                        ? Color.primary
                                        : Color.clear
                                )
                        )
                        .gitaHeaderCircleGlass(
                            glassID: "chatSendOrb",
                            glassNamespace: chatComposerChrome
                        )
                }
                .buttonStyle(.plain)
                .disabled(!vm.canSubmit || vm.isLoading)
                .animation(.easeInOut(duration: 0.15), value: vm.canSubmit)
            }
        }
    }

    // MARK: - Submit

    private func handleSubmit() {
        guard vm.canSubmit else { return }
        Task { await vm.handleFreeTextSubmit(allVerses: gitaVM.verses) }
    }

    private func handleMoodTap(_ mood: Mood) {
        Task { await vm.handleMoodSelection(mood) }
    }

    private func messageRow(_ message: ChatMessage) -> some View {
        switch message {
        case .userMood(_, let mood):
            return AnyView(userMoodRow(mood))
        case .userText(_, let text):
            return AnyView(userTextRow(text))
        case .assistantText(_, let fullText):
            return AnyView(assistantTextRow(fullText))
        case .assistantCards(_, let response):
            return AnyView(assistantMoodCardsRow(response))
        case .assistantFreeTextCards(_, let response):
            return AnyView(assistantFreeTextCardsRow(response))
        }
    }

    private func userMoodRow(_ mood: Mood) -> some View {
        HStack {
            Spacer(minLength: 32)
            Text("I’m feeling \(mood.label.lowercased())")
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineSpacing(5)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.primary)
                )
        }
    }

    private func userTextRow(_ text: String) -> some View {
        HStack {
            Spacer(minLength: 32)
            Text(text)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .lineSpacing(5)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    Capsule(style: .continuous)
                        .fill(Color.primary)
                )
        }
    }

    private func assistantMoodCardsRow(_ response: ChatMoodResponse) -> some View {
        HStack {
            Button {
                router.push(.moodResults(mood: response.mood, verseIDs: response.verseIDs))
            } label: {
                HStack(alignment: .center, spacing: 14) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(response.cardTitle)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text(response.subtitle)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 12)

                    Text("Open")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(.thinMaterial, in: Capsule(style: .continuous))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.9))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                }
                .gitaInputFieldGlass(
                    cornerRadius: 24,
                    glassID: "cardsResponse-\(response.id.uuidString)",
                    glassNamespace: responseCardChrome
                )
            }
            .buttonStyle(.plain)

            Spacer(minLength: 32)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func assistantFreeTextCardsRow(_ response: ChatFreeTextResponse) -> some View {
        HStack {
            Button {
                router.push(.freeTextResults(title: response.title, verseIDs: response.verseIDs))
            } label: {
                HStack(alignment: .center, spacing: 14) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(response.cardTitle)
                            .font(.system(size: 15, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text(response.subtitle)
                            .font(.system(size: 12, weight: .regular, design: .rounded))
                            .foregroundStyle(.secondary)
                    }

                    Spacer(minLength: 12)

                    Text("Open")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 8)
                        .background(.thinMaterial, in: Capsule(style: .continuous))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.9))
                )
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.primary.opacity(0.08), lineWidth: 0.5)
                }
                .gitaInputFieldGlass(
                    cornerRadius: 24,
                    glassID: "freeTextResponse-\(response.id.uuidString)",
                    glassNamespace: responseCardChrome
                )
            }
            .buttonStyle(.plain)

            Spacer(minLength: 32)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func assistantTextRow(_ text: String) -> some View {
        TypewriterTextBubble(text: text)
    }

    private var thinkingRow: some View {
        HStack {
            HStack(spacing: 8) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .scaleEffect(0.8)

                Text("Thinking…")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.thinMaterial, in: Capsule(style: .continuous))

            Spacer(minLength: 32)
        }
        .transition(.opacity)
    }

    private func scrollToLatest(_ proxy: ScrollViewProxy) {
        guard let lastID = vm.messages.last?.id else { return }
        let target: AnyHashable = (vm.isAwaitingMoodResponse || vm.isLoading) ? "thinking" : lastID
        withAnimation(.easeOut(duration: 0.25)) {
            proxy.scrollTo(target, anchor: .bottom)
        }
    }
}

// MARK: - Infinite auto-scroll chip row

/// Drives the offset for one chip row via a 60 fps Timer.
/// Using a class (not @State) so the Timer callback can mutate state without a struct capture problem.
private final class ChipScrollState: ObservableObject {
    @Published var offset: CGFloat = 0

    var stripWidth: CGFloat = 0
    var additionalVelocity: CGFloat = 0  // pts/sec injected by a drag; decays each tick
    var prevDragTranslation: CGFloat = 0

    let autoDirection: CGFloat  // -1 = right-to-left, +1 = left-to-right
    private let baseSpeed: CGFloat = 32  // pts/sec auto-scroll
    private let chipSpacing: CGFloat = 10
    private var timer: Timer?

    init(direction: CGFloat) { autoDirection = direction }

    /// Called once when the first chipStrip reports its width.
    func configure(stripWidth w: CGFloat) {
        guard stripWidth == 0, w > 0 else { return }
        stripWidth = w
        // Right-to-left starts at 0 and drifts negative; left-to-right starts at −totalWidth and drifts toward 0.
        offset = autoDirection < 0 ? 0 : -(w + chipSpacing)
        startTimer()
    }

    func startTimer() {
        guard timer == nil else { return }
        let t = Timer(timeInterval: 1.0 / 60.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func tick() {
        guard stripWidth > 0 else { return }
        let total = stripWidth + chipSpacing

        offset += (baseSpeed * autoDirection + additionalVelocity) / 60.0

        // Exponential decay — roughly halves the added velocity every ~0.4 s
        additionalVelocity *= 0.90
        if abs(additionalVelocity) < 0.5 { additionalVelocity = 0 }

        // Seamless wrap
        if autoDirection < 0 {
            while offset < -total { offset += total }
            while offset > 0     { offset -= total }
        } else {
            while offset > 0      { offset -= total }
            while offset < -total { offset += total }
        }
    }
}

/// A continuously auto-scrolling row of mood chips.
/// direction = -1 → chips drift right-to-left; +1 → left-to-right.
/// Drag anywhere on the row to add/subtract velocity; tapping a chip still fires normally.
private struct AutoScrollChipRow: View {
    let moods: [Mood]
    let direction: CGFloat
    let onTap: (Mood) -> Void
    let isDisabled: Bool

    @StateObject private var scroll: ChipScrollState

    init(moods: [Mood], direction: CGFloat, onTap: @escaping (Mood) -> Void, isDisabled: Bool) {
        self.moods = moods
        self.direction = direction
        self.onTap = onTap
        self.isDisabled = isDisabled
        _scroll = StateObject(wrappedValue: ChipScrollState(direction: direction))
    }

    var body: some View {
        GeometryReader { _ in
            HStack(spacing: 10) {
                chipStrip
                    // Measure the natural width of one copy so we know how far to loop
                    .background(
                        GeometryReader { g in
                            Color.clear.onAppear { scroll.configure(stripWidth: g.size.width) }
                        }
                    )
                chipStrip  // seamless duplicate
            }
            .offset(x: scroll.offset)
            // simultaneousGesture lets Buttons inside still receive taps
            .simultaneousGesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { value in
                        let delta = value.translation.width - scroll.prevDragTranslation
                        scroll.prevDragTranslation = value.translation.width
                        scroll.offset += delta
                        scroll.additionalVelocity = 0  // suppress auto-decay while finger is down
                    }
                    .onEnded { value in
                        scroll.prevDragTranslation = 0
                        scroll.additionalVelocity = value.velocity.width
                    }
            )
        }
        .frame(height: 42)
        .clipped()
        .onDisappear { scroll.stopTimer() }
    }

    private var chipStrip: some View {
        HStack(spacing: 10) {
            ForEach(moods) { mood in
                Button { onTap(mood) } label: {
                    HStack(spacing: 7) {
                        Group {
                            if UIImage(named: mood.id) != nil {
                                Image(mood.id)
                                    .resizable()
                                    .scaledToFit()
                                    .blendMode(.multiply)
                            } else {
                                Image(systemName: mood.symbol)
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundStyle(.primary)
                            }
                        }
                        .frame(width: 20, height: 20)

                        Text("For \(mood.label)")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.primary)
                            .fixedSize()
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(.regularMaterial, in: Capsule(style: .continuous))
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.5)
                    }
                }
                .buttonStyle(GlassChipButtonStyle())
                .disabled(isDisabled)
            }
        }
    }
}

// MARK: - Glass chip button style

/// Slight scale-down on press.
private struct GlassChipButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    let coordinator = AppCoordinator()
    NavigationStack {
        ChatView()
            .environmentObject(GitaViewModel())
            .environmentObject(NavigationRouter())
            .environmentObject(coordinator)
            .environmentObject(coordinator.chatViewModel)
    }
}
