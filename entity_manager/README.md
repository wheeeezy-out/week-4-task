# Entity Manager (Flutter)

Minimal entity record management app with **Add, Update, Delete, Search**.

## Open in Android Studio
1. Unzip the folder.
2. `File → Open…` and select the `entity_manager` folder.
3. In a terminal at the project root, run:
   ```bash
   flutter create .
   flutter pub get
   flutter run
   ```
   (`flutter create .` regenerates the platform folders — android/ios/web — for your Flutter SDK.)

## Structure
- `lib/main.dart` — entire app: model, list, search, add/edit form, delete.
- `pubspec.yaml` — only `flutter` + `cupertino_icons`.

Total app logic: ~150 lines, Material 3, fully responsive.