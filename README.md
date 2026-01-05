![banner.png](banner.png)

# A Dish A Day

Your family's recipe collection deserves a home. A Dish A Day is an iOS app for preserving and organizing cherished family recipes. From grandma's secret apple pie to mom's Sunday roast.

Plan your meals for the week, digitize handwritten recipe cards, and keep generations of culinary traditions alive in one beautiful app.

## Features

- **Family Recipe Collection** - Store and organize recipes passed down through generations, complete with photos and personal notes
- **Meal Planning** - Schedule recipes on a calendar to plan your week's meals
- **Recipe Scanning** - Snap a photo of grandma's handwritten recipe card and let AI extract the ingredients and steps
- **Reminders** - Get notified when it's time to start cooking
- **Share with Family** - Export recipe calendars to share with loved ones
- **Starter Recipes** - Bundled recipe collections featuring our favorites to get you cooking

## Requirements

- iOS 17.0+
- Xcode 15.0+
- OpenAI API key (optional, for recipe scanning)

## Development Setup

1. Clone the repository
2. Install tools: `brew install swiftlint typos-cli periphery`
3. Enable git hooks: `git config core.hooksPath scripts/hooks`
4. Open `ADishADay.xcodeproj` in Xcode (or [Cursor](https://cursor.sh) with [SweetPad](https://sweetpad.hzbd.me))
5. Build and run on simulator or device

### Hot Reloading with Inject

This project supports hot reloading via [Inject](https://github.com/krzysztofzablocki/Inject). To enable it:

1. Download [InjectionIII](https://github.com/johnno1962/InjectionIII/releases) and place it in `/Applications`. Use the GitHub release instead of the App Store version.
2. Build and run your app in the simulator

The injection bundle loads automatically. Save any Swift file and changes appear instantly without rebuilding!

### Finding Unused Code

Run [Periphery](https://github.com/peripheryapp/periphery) periodically to find dead code:

```bash
periphery scan --project ADishADay.xcodeproj --schemes "A Dish A Day"
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
