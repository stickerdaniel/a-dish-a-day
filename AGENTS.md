# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) and other AI code assistants when working with code in this repository.

## Project Overview

"A Dish A Day" is a SwiftUI iOS app combining recipe management with calendar scheduling. Users create calendars with recipes assigned to specific unlock dates, with notification support for recipe unlocks.

## Build & Development

**Build Tool:** Xcode (native iOS)
- Open `ADishADay.xcodeproj` in Xcode
- Build target: ADishADay
- No command-line build scripts; use Xcode or `xcodebuild`

**No test targets configured** - ENABLE_TESTABILITY is set but no tests exist yet.

## Architecture

**Pattern:** MVVM with SwiftData persistence

### Data Layer
- `RecipeModel` (@Model + Codable): Standalone recipes in Recipes tab
- `RecipeData` (struct + Codable): Recipes embedded in calendars with unlock dates
- `CalendarModel` (@Model + Codable): Calendar scheduling with start/end dates

### View Structure
```
ContentView (TabView)
├── CalendarsView
│   ├── CalendarCard
│   ├── EditCalendarView → DaySelection → RecipeSelection
│   └── OpenCalendarView
├── RecipesView
│   ├── RecipeCard
│   ├── EditRecipeView (includes AI scan, markdown import)
│   └── OpenRecipeView
└── SettingsView
```

### State Management
- `@Query` for SwiftData queries
- `@AppStorage` for user preferences (appearance, notifications, API keys)
- `@Environment(\.modelContext)` for database operations

## Key Directories

- `ADishADay/Model/` - SwiftData models
- `ADishADay/Views/` - SwiftUI views (organized by feature)
- `ADishADay/Views/ReusableComponents/` - Shared UI components (Card, PhotoPicker, etc.)
- `ADishADay/Utilities/` - Helper services (OpenAI client, notifications, import/export)
- `ADishADay/DefaultCalendars/` - Bundled .ddcal calendar files

## Key Features

**Recipe Unlock System:**
- `RecipeData.unlockDate` controls when recipes become available
- `isUnlocked` computed property checks if current date >= unlock date
- Badge system (BadgeType enum) shows lock status

**OpenAI Integration:**
- `OpenAIClient.swift` uses gpt-4o-mini for recipe extraction from images
- API key stored via @AppStorage("openai_api_key")

**Notifications:**
- `NotificationManager.shared` singleton handles scheduling
- Calendar-based notification grouping

**Import/Export:**
- `.ddcal` custom format (ZIP-based JSON with embedded images)
- `CalendarSerialization.swift` handles encoding/decoding
- Default calendars loaded from bundle on first launch

## Custom Types

```swift
enum BadgeType { case none, indicator, warning, locked }
enum Appearance { case light, dark, system }
enum CalendarSource { case created, imported }
```

## Dependencies

- SwiftUI, SwiftData, UserNotifications (native)
- Inject (development hot reload)
- OpenAI API (external, requires API key)
- When creating a SwiftUI view, add @ObserveInjection var inject as a property and .enableInjection() at the end of the body to enable hot reload - leave it in, it's a no-op in release builds.

## Code Quality

This project uses three tools for code quality:

| Tool | Purpose | When it runs |
|------|---------|--------------|
| **swift-format** | Code formatting | Pre-commit hook, format-on-save |
| **SwiftLint** | Code linting | Pre-commit hook, Xcode build |
| **typos** | Spell checking | Pre-commit hook |

### Pre-commit Hook

The pre-commit hook (`scripts/hooks/pre-commit`) runs:
1. **swift-format** - Auto-formats staged Swift files
2. **SwiftLint** - Lints staged Swift files (blocks commit on errors)
3. **typos** - Checks spelling in all staged files

### swift-format (Formatting)

- **Config:** `.swift-format`
- **VS Code:** Format-on-save via [SweetPad](https://sweetpad.hyzyla.dev/docs/intro/)
- **Xcode:** Built into toolchain at `/Applications/Xcode.app/.../usr/bin/swift-format`

### SwiftLint (Linting)

- **Config:** `.swiftlint.yml` (strict mode - all warnings are errors)
- **Install:** `brew install swiftlint`
- **Rules:** https://realm.github.io/SwiftLint/rule-directory.html

### typos (Spell Checking)

- **Config:** `_typos.toml` (for custom words/exclusions)
- **Install:** `brew install typos-cli`
- **Fix typos:** `typos -w` to auto-fix

### Setup (one-time per machine)

```bash
brew install swiftlint typos-cli
git config core.hooksPath scripts/hooks
```

The Xcode build will fail with instructions if git hooks aren't configured.
