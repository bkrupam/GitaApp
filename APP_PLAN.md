# GitaApp Plan

This plan is the source of truth for what is pending, what is ready, and what to pick up next. The current focus is **making the app work beautifully on this laptop and on a real iPhone**, not App Store submission.

## Agent Tracking Protocol

At the start of every implementation prompt:

1. Read this file first.
2. Check the relevant code before changing anything.
3. Pick the highest-priority unchecked task that matches the user's request.
4. When a task is completed and verified, mark it as `[x]` and change its status to `Ready`.
5. Add a short note to the `Progress Log` with the date, what changed, and how it was verified.
6. Do not start App Store readiness work unless the user explicitly asks for it.

Status meanings:

- `Pending`: not started.
- `In Progress`: started but not verified.
- `Ready`: implemented and verified on simulator, build, or device as appropriate.
- `Deferred`: intentionally out of scope for now.
- `Blocked`: waiting on user input or external content.

## Current Snapshot

- The app has local SwiftUI browsing, card flipping, chapter index, mood curation, chat UI, and Liquid Glass-style visual polish.
- `verses.json` contains **200 verses, chapters 1–4**.
- **Gemini** is wired via `GeminiClient` + `GeminiCurationService`. Works when `GeminiSecrets.plist` is added to the app target; otherwise falls back to keyword matching and verse-based offline learn-more text.
- Mood verse IDs are fixed for the current bundled corpus.
- Free-text chat now follows the same bubble → thinking → cards flow as mood selection.

## Phase 1: High-Priority App Functionality

| Ready | Status | Task | Notes |
| --- | --- | --- | --- |
| [ ] | Blocked | Complete the remaining Gita chapter data | Needs chapters 5–18 content from you (same JSON shape as ch 1–4). |
| [x] | Ready | Validate verse data integrity | `VerseDataValidator.swift` + `Scripts/validate_verses.py`. |
| [x] | Ready | Fix mood verse IDs | All 12 moods now reference valid IDs 1–200. |
| [x] | Ready | Define Gemini integration shape | Direct Gemini REST from iOS via `GeminiSecrets.plist` (local dev). Optional backend hook in `RemoteCurationService.endpointURL`. |
| [x] | Ready | Implement free-text curation with Gemini/backend | `GeminiCurationService` with keyword fallback when no API key. |
| [x] | Ready | Implement `Learn more` with verse context | Passes full verse via `pendingLearnMoreVerse`; Gemini or offline fallback. |
| [x] | Ready | Remove demo-only AI delays | Removed fake `Task.sleep` from mood/learn-more paths. |
| [x] | Ready | Improve AI error states | Friendly alerts for missing key, rate limits, and failures. |
| [x] | Ready | Align free-text chat UX | Free text now shows user bubble → thinking → assistant → View cards CTA. |

### Gemini setup (required for live AI)

1. Copy `GitaApp/GeminiSecrets.plist.example` → `GitaApp/GeminiSecrets.plist`
2. Paste your API key from [Google AI Studio](https://aistudio.google.com/apikey)
3. In Xcode, add `GeminiSecrets.plist` to the **GitaApp** target (Copy Bundle Resources if needed)
4. Run on simulator or device — Chat free-text and Learn more will use Gemini

Without the plist, the app still runs with keyword curation and offline learn-more excerpts.

## Phase 2: Make It Feel Beautiful on Laptop and iPhone

| Ready | Status | Task | Notes |
| --- | --- | --- | --- |
| [x] | Ready | Verify build and run locally | Simulator build succeeded (`xcodebuild`, Debug-iphonesimulator). |
| [ ] | Pending | Test on iPhone simulator | Manual UI pass on small + large simulators. |
| [ ] | Pending | Test on physical iPhone | Requires signing team in Xcode. |
| [ ] | Pending | Polish chat input behavior | Keyboard, send, scroll-to-latest. |
| [ ] | Pending | Polish card browsing performance | Snap scroll, flip, backgrounds. |
| [ ] | Pending | Improve empty states | When curation returns no valid verses. |
| [ ] | Pending | Add practical accessibility pass | VoiceOver labels on core controls. |
| [ ] | Pending | Review forced light mode | Decide keep or add dark mode. |

## Phase 3: Product Features

Start after Phase 1 content (ch 5–18) and Phase 2 device polish.

| Ready | Status | Task | Notes |
| --- | --- | --- | --- |
| [ ] | Pending | Persist reading progress | |
| [ ] | Pending | Add bookmarks/favorites | |
| [ ] | Pending | Add search | |
| [ ] | Pending | Add chapter titles | |
| [ ] | Pending | Add share verse/card | |
| [ ] | Pending | Add settings screen | |
| [ ] | Pending | Add simple onboarding | |

## Phase 4: Deferred App Store Readiness

| Ready | Status | Task | Notes |
| --- | --- | --- | --- |
| [ ] | Deferred | App icon and launch polish | |
| [ ] | Deferred | Privacy manifest | |
| [ ] | Deferred | Legal/privacy/terms content | |
| [ ] | Deferred | Test target and release checks | |
| [ ] | Deferred | App Store metadata | |

## Progress Log

- 2026-05-22: Created plan from app audit.
- 2026-05-22: Phase 1 (except ch 5–18 data): fixed mood verse IDs; added `VerseDataValidator`, `GeminiClient`, `GeminiCurationService`; aligned free-text chat UX; learn-more with verse context; removed demo delays; improved error messages. Verified `validate_verses.py` OK and simulator build succeeded.
- 2026-05-24: Verse home + mood results visual refresh — dark-to-vibrant chapter canvas (`VerseBackgroundView`), frosted verse cards (`FrostedChrome`), white chrome on canvas (tab bar, progress, chapter menu). Simulator build succeeded (iPhone 17).
- 2026-05-24: Softened the verse home top chrome — clear Liquid Glass tab track, lighter header tint, and gentler scroll fade so the navigation blends into the canvas. Verified with simulator build (`iPhone 17 Pro`).
- 2026-05-24: Neutralized the verse tab track tint and adjusted card sizing/fades so previous and next cards are more visible. Verified with simulator build (`iPhone 17 Pro`).
- 2026-05-26: Curated mood/chat results — single neutral `VersePalette.curatedResults` for canvas and all cards (no per-verse hue mixing); Liquid Glass back orb and mood pill header on iOS 26. Verified simulator build (`iPhone 17 Pro`).
