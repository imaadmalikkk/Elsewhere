# Single-Pane Config Redesign

## Problem
The current NavigationSplitView with 3 sidebar items (Clocks, Appearance, General) is over-structured for the small amount of content. It feels heavy and un-Apple-like.

## Design
Replace with a single scrollable `Form` using `.formStyle(.grouped)` for native macOS grouped-section appearance.

### Layout (top to bottom)
1. **Search** — inline TextField at top to add cities
2. **Cities section** — each city as a row: flag, name, UTC info, time. Hover reveals remove button.
3. **Menu Bar section** — Picker with `.radioGroup` for display format + live preview
4. **General section** — Toggle for Launch at Login
5. **Footer** — "Elsewhere v2.0" centered caption

### Window
- Width: ~400px (down from 540)
- Remove `.fullSizeContentView`
- Keep `.toolbarStyle(.unified)`

### Deletions
- `ConfigSection` enum
- `AppearanceTab`, `GeneralTab`, `ClocksTab` (merged into one view)
- `FormatOptionRow` (replaced by native Picker)

### Kept
- `ClockCard` component
- `MenuBarPreview` widget
- Inline search logic

## Files Changed
- `Sources/Elsewhere/ConfigView.swift` — full rewrite
- `Sources/Elsewhere/ConfigWindowController.swift` — window size adjustments
