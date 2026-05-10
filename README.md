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
