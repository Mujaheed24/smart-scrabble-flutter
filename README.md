# 🧩 Smart Scrabble

A fully functional, offline-first Scrabble companion and game engine built with Flutter and Dart. 

## ✨ Features
* **Advanced Game Engine:** Mathematically accurate scoring, including multi-word intersection validation and Bingo (+50) bonuses.
* **Inline Draft System:** Seamlessly draft and preview words on the board before committing your turn.
* **Offline Dictionary:** Lightning-fast word validation using a custom Trie data structure.
* **Local Persistence:** Auto-saves game state, players, and timer settings using `Hive` so you never lose a match.
* **Custom Matches:** Supports 2 to 4 players with an optional, toggleable turn timer.
* **History Stack:** Full Undo support to revert board states and scores.

## 🛠️ Built With
* [Flutter](https://flutter.dev/)
* [Provider](https://pub.dev/packages/provider) (State Management)
* [Hive](https://pub.dev/packages/hive) (Local Storage)

## 📱 How to Install and Play

### For Android Users (Quick Install)
If you just want to play the game on your Android phone, you don't need to download the code!
1. Go to the **[Releases](#)** section on the right side of this GitHub page. *(Note: Add the link to your releases page here later)*
2. Download the `app-release.apk` file to your Android device.
3. Tap the downloaded file to install it. *(You may need to allow "Install from Unknown Sources" in your phone's settings).*
4. Open the app and enjoy!

### For Developers (Build from Source)
If you want to explore the code or run it on iOS/Web, follow these steps:

**Prerequisites:**
* [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.
* A physical device or an emulator running.

**Steps:**
1. Clone this repository:
   ```bash
   git clone [https://github.com/Mujaheed24/smart-scrabble-flutter.git](https://github.com/Mujaheed24/smart-scrabble-flutter.git)
2. Navigate into the project directory:
   ```bash
   cd smart-scrabble-flutter

4. Install the dependencies:
   ```bash
   flutter pub get

5. Run the app:
   ```bash
   flutter run
