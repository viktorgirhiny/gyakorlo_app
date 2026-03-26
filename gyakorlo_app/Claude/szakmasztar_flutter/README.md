# Szakmasztar - Flutter Version

Flutter/Dart conversion of the SwiftUI iOS quiz app.

## Setup

1. Install Flutter: https://flutter.dev/docs/get-started/install
2. Run in your project folder:

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart                  # App entry + Splash screen
├── models/
│   ├── question.dart          # Question model + AnswerState enum
│   └── stats_manager.dart     # Stats & streak system (SharedPreferences)
├── providers/
│   └── quiz_provider.dart     # Quiz state (ChangeNotifier = ObservableObject)
├── screens/
│   ├── main_menu_screen.dart  # Main menu + mode picker + side menu
│   ├── quiz_screen.dart       # Quiz + answer buttons
│   ├── result_screen.dart     # Result + animated ring + answers list
│   └── stats_screen.dart      # Statistics screen
└── theme/
    └── app_theme.dart         # Colors + theme helpers

assets/
└── questions.json             # 100 Hungarian IT/networking questions
```

## What maps to what

| Swift/SwiftUI        | Flutter/Dart              |
|---------------------|---------------------------|
| @StateObject         | ChangeNotifierProvider    |
| @ObservedObject      | context.watch<>()         |
| @AppStorage          | SharedPreferences         |
| UserDefaults         | SharedPreferences         |
| VStack               | Column                    |
| HStack               | Row                       |
| ZStack               | Stack                     |
| Spacer()             | Spacer() / SizedBox       |
| .sheet               | showModalBottomSheet      |
| .fullScreenCover     | Navigator.push            |
| SF Symbols           | Material Icons            |
| Combine Timer        | dart:async Timer          |
| LinearGradient       | LinearGradient            |
| .glassEffect()       | Not available on Android  |

## Notes

- `.glassEffect()` is iOS 26 only and is NOT available in Flutter.
  The result and main menu buttons use standard containers instead.
- SF Symbols are replaced with the closest Material Icons equivalent.
- The app works on both iOS and Android from the same codebase.
