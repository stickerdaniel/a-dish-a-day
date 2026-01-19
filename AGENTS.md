# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code) and other AI code assistants when working with code in this repository.

## Project Overview

"A Dish A Day" is a SwiftUI iOS app combining recipe management with calendar scheduling. Users create calendars with recipes assigned to specific unlock dates, with notification support for recipe unlocks.


### Setup (one-time per machine)

```bash
brew install swiftlint typos-cli periphery
git config core.hooksPath scripts/hooks
```

The Xcode build will fail with instructions if git hooks aren't configured.


## Build & Development

**Build Tool:** Xcode (native iOS)
- Open `ADishADay.xcodeproj` in Xcode
- Build target: ADishADay
- No command-line build scripts; use Xcode or `xcodebuild` (or user)


## Convex Backend Development

Deployment: `https://jovial-firefly-799.convex.cloud`

### Initial Setup (one-time)

```bash
# Install dependencies
bun install

# Link to existing deployment (select jovial-firefly-799)
bunx convex dev
```

### Development Workflow

```bash
# Terminal 1: Start Convex dev server (watches for changes, syncs to cloud)
bunx convex dev

# Terminal 2: Run Xcode
```

### Commands Reference

| Command | Purpose |
|---------|---------|
| `bunx convex dev` | Start dev server with hot reload |
| `bunx convex deploy` | Deploy to production |
| `bunx convex import --table <name> <file.jsonl>` | Import data |
| `bunx convex export --path <dir>` | Export all data |
| `bunx convex dashboard` | Open Convex dashboard |

### Adding New Convex Functions

1. Create `.ts` file in `convex/` directory
2. `bunx convex dev` auto-deploys changes
3. Create matching Swift `Decodable` struct in `ADishADay/Model/ConvexModels/`
4. **Queries**: Subscribe in SwiftUI view using `.task { for await ... }`
5. **Mutations**: Call with `convex.mutation("function:name", with: args)`

### Tutorial Example (DiscoverView)

The Discover tab demonstrates Convex integration with a simple task list:

**Backend** (`convex/tasks.ts`):
- `tasks:get` query - Returns all tasks
- `tasks:toggle` mutation - Toggles task completion

**Frontend** (`DiscoverView.swift`):
- Real-time subscription to `tasks:get`
- Tap tasks to toggle completion via `tasks:toggle` mutation
- Updates appear instantly across all connected clients

### Project Structure

```
convex/
├── _generated/     # Auto-generated (gitignored)
├── tasks.ts        # Task queries & mutations (tutorial example)
└── schema.ts       # Optional: explicit schema
```


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
- SwiftDate (date manipulation library)
- Convex (backend platform Swift SDK)
- OpenAI API (external, requires API key)
- When creating a SwiftUI view, add @ObserveInjection var inject as a property and .enableInjection() at the end of the body to enable hot reload - leave it in, it's a no-op in release builds.

### Inject + Convex Compatibility

**Important:** The `-Xlinker -interposable` linker flags have been intentionally removed from this project to allow ConvexMobile (Rust-based SDK) to load properly.

**Why:** ConvexMobile uses Rust FFI with serde symbols. When `-interposable` is enabled, Xcode creates a `.debug.dylib` that cannot resolve these Rust symbols, causing a runtime crash:
```
dyld: Symbol not found: __ZN41_$LT$T$u20$as$u20$serde..de..Expected$GT$3fmt...
```

**Impact on Inject:**
- Hot reload **works** for class methods (via swizzling)
- Hot reload **does not work** for structs, enums, or free functions (requires interposing)
- SwiftUI views using `@ObserveInjection` still work since they use class-based observation


## btca

When you need up-to-date information about technologies used in this project, use btca to query source repositories directly.

**Available resources**: inject, swiftDate, convex, convexAuth0

### Usage

```bash
btca ask -r <resource> -q "<question>"
```

Use multiple `-r` flags to query multiple resources at once:

```bash
btca ask -r swiftDate -r convex -q "How do I integrate Convex with SwiftDate for timestamp handling?"
```

## Code Quality

| Tool | Purpose | When to run |
|------|---------|-------------|
| **swift-format** | Code formatting | Pre-commit hook, CI, format-on-save |
| **SwiftLint** | Code linting | Pre-commit hook, CI |
| **typos** | Spell checking | Pre-commit hook, CI |
| **Periphery** | Find unused code | Manually, periodically |

### Quality Checks Script

The unified quality checks script (`scripts/quality-checks.sh`) runs all checks:

```bash
# Run on all files (CI mode)
./scripts/quality-checks.sh

# Run on staged files only (pre-commit mode)
./scripts/quality-checks.sh --staged
```

**Checks performed:**
1. **swift-format** - Auto-formats Swift files
2. **SwiftLint** - Lints Swift files (blocks on errors)
3. **typos** - Checks spelling (always on all files, uses typos.toml)

### Pre-commit Hook

The pre-commit hook (`scripts/hooks/pre-commit`) calls `quality-checks.sh --staged`:
- swift-format and SwiftLint run on staged files only
- typos runs on all files (uses typos.toml for exclusions)

### CI Workflow

GitHub Actions workflow (`.github/workflows/quality-checks.yml`) runs on:
- Push to `main` branch
- Pull request creation/updates

Uses `macos-latest` runner with `./scripts/quality-checks.sh` (full mode).

### swift-format (Formatting)

- **Config:** `.swift-format`
- **VS Code:** Format-on-save via [SweetPad](https://sweetpad.hyzyla.dev/docs/intro/)
- **Xcode:** Built into toolchain at `/Applications/Xcode.app/.../usr/bin/swift-format`

### SwiftLint (Linting)

- **Config:** `.swiftlint.yml` (strict mode - all warnings are errors)
- **Rules:** https://realm.github.io/SwiftLint/rule-directory.html

### typos (Spell Checking)

- **Config:** `_typos.toml` (for custom words/exclusions)
- **Fix typos:** `typos -w` to auto-fix

### Periphery (Dead Code Detection)

- **Run:** `periphery scan --project ADishADay.xcodeproj --schemes "A Dish A Day"`
- **Use:** Run periodically to find unused declarations, parameters, and protocols
- **Docs:** https://github.com/peripheryapp/periphery

Suggest to run Periphery after every successful test of a feature implementation.

After running Periphery, evaluate each finding. Remove truly dead code, but document intentionally kept code below.

#### Intentionally Kept (Do Not Remove)

Document any unused code that should be kept here. When Periphery reports these items, they can be safely ignored.

| Item | File | Reason |
|------|------|--------|
| `nextUnlockTime` | CalendarModel.swift | Infrastructure for future notification scheduling (e.g., remind user before next recipe unlocks) |
| `startOfMonth` | BetterDateUtilities.swift | Non-trivial date utility for month boundary operations |
| `endOfMonth` | BetterDateUtilities.swift | Pairs with `startOfMonth` for complete month boundary API |
