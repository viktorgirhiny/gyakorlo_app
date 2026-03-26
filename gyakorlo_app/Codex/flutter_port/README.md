# Flutter Port

This folder contains a Flutter recreation of the SwiftUI quiz app.

Current contents:
- `lib/` with Dart equivalents of the Swift files
- `assets/questions.json` copied from the iOS app
- `pubspec.yaml` with the required Flutter dependencies

Notes:
- Flutter is not installed in this environment, so the app code was ported but not compiled here.
- If you install Flutter locally, you can generate the missing runner files inside this folder with:
  - `flutter create . --platforms=android`
  - `flutter pub get`
  - `flutter run`
