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

## Code Formatting

This project uses `swift-format` for consistent code style.

**VS Code:** Format-on-save via [Sweetpad](https://marketplace.visualstudio.com/items?itemName=sweetpad.sweetpad) extension (`.vscode/settings.json`)
- Install: [VS Code Marketplace](https://marketplace.visualstudio.com/items?itemName=sweetpad.sweetpad)
- Docs: https://sweetpad.hyzyla.dev/docs/intro/

**Git Hooks:** Pre-commit hook auto-formats staged Swift files.

**Xcode:** Build phase "Check Git Hooks" fails build if hooks aren't configured.

### Setup (one-time per machine)

Run this command to enable git hooks:
```bash
git config core.hooksPath scripts/hooks
```

The Xcode build will fail with instructions if this isn't configured.
