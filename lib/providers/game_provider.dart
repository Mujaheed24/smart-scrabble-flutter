import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/player.dart';
import '../models/tile.dart';
import '../services/dictionary_service.dart';


class GameProvider with ChangeNotifier {
  List<Player> players = [];
  int currentPlayerIndex = 0;
  List<Tile?> board = List.filled(225, null);
  
  final DictionaryService _dictionaryService = DictionaryService();
  bool isDictionaryLoaded = false;
  
  Timer? _turnTimer;
  int timeLeft = 180;
  bool useTimer = true;

  // --- DRAFT SYSTEM STATE ---
  int? selectedSquare;
  bool isDraftHorizontal = true;
  String draftWord = "";
  String draftError = "";

  final List<int> tw = [0, 7, 14, 105, 119, 210, 217, 224];
  final List<int> dw = [16, 28, 32, 42, 48, 56, 64, 70, 112, 154, 160, 168, 176, 182, 192, 196, 208];
  final List<int> tl = [20, 24, 76, 80, 84, 88, 136, 140, 144, 148, 200, 204];
  final List<int> dl = [3, 11, 36, 38, 45, 59, 92, 96, 98, 102, 108, 116, 122, 126, 128, 132, 165, 179, 186, 188, 213, 221];

  final Map<String, int> tileValues = {
    'A':1, 'B':3, 'C':3, 'D':2, 'E':1, 'F':4, 'G':2, 'H':4, 'I':1, 'J':8, 'K':5, 'L':1, 'M':3, 
    'N':1, 'O':1, 'P':3, 'Q':10, 'R':1, 'S':1, 'T':1, 'U':1, 'V':4, 'W':4, 'X':8, 'Y':4, 'Z':10,
  };

  // --- HISTORY STATE ---
  List<Map<String, dynamic>> matchHistory = [];

  GameProvider() { _loadDictionary(); }

  Future<void> _loadDictionary() async {
    await _dictionaryService.load();
    isDictionaryLoaded = true;
    notifyListeners();
  }

  String getBonus(int index) {
    if (tw.contains(index)) return 'TW';
    if (dw.contains(index)) return 'DW';
    if (tl.contains(index)) return 'TL';
    if (dl.contains(index)) return 'DL';
    return '';
  }

  void startTimer() {
    _turnTimer?.cancel();
    if (!useTimer) return;
    timeLeft = 180;
    _turnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) { timeLeft--; notifyListeners(); } else { skipTurn(); }
    });
  }

  void startGame(List<String> playerNames, {bool enableTimer = true}) {
    players = playerNames.map((name) => Player(name: name)).toList();
    currentPlayerIndex = 0;
    board = List.filled(225, null);
    useTimer = enableTimer;
    clearDraft();
    startTimer();
    saveGame();
    notifyListeners();
  }

  void saveGame() {
    var box = Hive.box('scrabbleBox');
    box.put('players', players.map((p) => p.toMap()).toList());
    box.put('currentPlayerIndex', currentPlayerIndex);
    box.put('board', board.map((t) => t?.toMap()).toList());
    box.put('useTimer', useTimer);
  }

  void loadGame() {
    var box = Hive.box('scrabbleBox');
    if (box.containsKey('players')) {
      var savedPlayers = box.get('players') as List;
      players = savedPlayers.map((p) => Player.fromMap(p)).toList();
      currentPlayerIndex = box.get('currentPlayerIndex', defaultValue: 0);
      var savedBoard = box.get('board') as List;
      board = savedBoard.map((t) => t != null ? Tile.fromMap(t) : null).toList();
      useTimer = box.get('useTimer', defaultValue: true);
      clearDraft();
      startTimer();
      notifyListeners();
    }
  }

  void skipTurn() {
    if (players.isEmpty) return;
    currentPlayerIndex = (currentPlayerIndex + 1) % players.length;
    clearDraft();
    startTimer();
    saveGame();
    notifyListeners();
  }

  // --- DRAFT METHODS ---
  void selectSquare(int index) {
    if (selectedSquare == index) {
      isDraftHorizontal = !isDraftHorizontal; 
    } else {
      selectedSquare = index;
      isDraftHorizontal = true;
    }
    draftWord = ""; 
    notifyListeners();
  }

  void updateDraft(String word) {
    draftWord = word;
    notifyListeners();
  }

  void clearDraft() {
    selectedSquare = null;
    draftWord = "";
    isDraftHorizontal = true;
    notifyListeners();
  }

  void _saveSnapshot() {
    // Keeps only the last 10 moves in memory to save performance
    if (matchHistory.length >= 10) matchHistory.removeAt(0); 
    
    matchHistory.add({
      'players': players.map((p) => p.toMap()).toList(),
      'board': board.map((t) => t?.toMap()).toList(),
      'currentPlayerIndex': currentPlayerIndex,
    });
  }

  void undo() {
    if (matchHistory.isEmpty) return;
    
    var lastState = matchHistory.removeLast();
    
    var savedPlayers = lastState['players'] as List;
    players = savedPlayers.map((p) => Player.fromMap(p)).toList();
    
    var savedBoard = lastState['board'] as List;
    board = savedBoard.map((t) => t != null ? Tile.fromMap(t) : null).toList();
    
    currentPlayerIndex = lastState['currentPlayerIndex'];
    
    clearDraft();
    startTimer();
    saveGame();
    notifyListeners();
  }

  bool commitDraft() {
    if (selectedSquare == null || draftWord.isEmpty) return false;
    bool success = _processMove(selectedSquare!, draftWord, isDraftHorizontal);
    if (success) clearDraft();
    return success;
  }

  // --- CORE ENGINE ---
  bool _processMove(int startIndex, String originalWord, bool isHorizontal) {
    if (players.isEmpty || !isDictionaryLoaded) return false;
    String upperWord = originalWord.toUpperCase();

    if (!_dictionaryService.isValid(upperWord)) {
      draftError = "'$upperWord' is not in the dictionary."; return false;
    }

    int step = isHorizontal ? 1 : 15;
    List<int> newIndices = [];
    bool sharesTile = false;

    // Boundary & Overlap Check
    for (int i = 0; i < upperWord.length; i++) {
      int pos = startIndex + (i * step);
      if (pos >= 225) { draftError = "Word goes off the board."; return false; }
      if (isHorizontal && i > 0 && pos % 15 == 0) { draftError = "Word wraps around the edge."; return false; }

      Tile? existing = board[pos];
      if (existing != null) {
        if (existing.letter != upperWord[i]) { draftError = "Conflicts with existing letters."; return false; }
        sharesTile = true;
      } else {
        newIndices.add(pos);
      }
    }

    if (newIndices.isEmpty) { draftError = "You must play at least one new tile."; return false; }

    // Connection Rules
    bool isFirstMove = !board.any((t) => t != null);
    if (isFirstMove) {
      if (!List.generate(upperWord.length, (i) => startIndex + (i * step)).contains(112)) {
        draftError = "The first word must cross the center star."; return false;
      }
    } else {
      bool connects = sharesTile;
      if (!connects) {
        for (int pos in newIndices) {
          if (pos % 15 != 0 && board[pos - 1] != null) connects = true; 
          if ((pos + 1) % 15 != 0 && board[pos + 1] != null) connects = true; 
          if (pos >= 15 && board[pos - 15] != null) connects = true; 
          if (pos <= 209 && board[pos + 15] != null) connects = true; 
        }
      }
      if (!connects) { draftError = "Word must connect to existing tiles."; return false; }
    }

    _saveSnapshot();

    // Score Main Word
    int mainScore = 0;
    int mainMult = 1;

    for (int i = 0; i < upperWord.length; i++) {
      int pos = startIndex + (i * step);
      int letterVal = tileValues[upperWord[i]] ?? 0;

      if (newIndices.contains(pos)) {
        String b = getBonus(pos);
        if (b == 'DL') letterVal *= 2;
        if (b == 'TL') letterVal *= 3;
        if (b == 'DW') mainMult *= 2;
        if (b == 'TW') mainMult *= 3;

      } else {
         letterVal = board[pos]!.value; 
      }
      mainScore += letterVal;
    }
    mainScore *= mainMult;

    // Score Cross Words
    int crossTotal = 0;
    int perpStep = isHorizontal ? 15 : 1; 

    for (int pos in newIndices) {
      int charIndex = isHorizontal ? (pos - startIndex) : (pos - startIndex) ~/ 15;
      String newLetter = upperWord[charIndex];
      int letterBaseVal = tileValues[newLetter] ?? 0;
      bool hasNeighbor = false;
      if (pos - perpStep >= 0 && (perpStep == 15 || pos % 15 != 0) && board[pos - perpStep] != null) hasNeighbor = true;
      if (pos + perpStep < 225 && (perpStep == 15 || (pos + 1) % 15 != 0) && board[pos + perpStep] != null) hasNeighbor = true;

      if (!hasNeighbor) continue;

      int current = pos;
      while (current - perpStep >= 0 && (perpStep == 15 || current % 15 != 0) && (board[current - perpStep] != null)) {
        current -= perpStep;
      }

      String crossWord = "";
      int crossScore = 0;
      int crossMult = 1;

      while (current < 225 && (perpStep == 15 || current % 15 != 0 || current == pos)) {
        if (current == pos) {
          crossWord += newLetter;
          int val = letterBaseVal;
          String b = getBonus(pos);
          if (b == 'DL') val *= 2;
          if (b == 'TL') val *= 3;
          if (b == 'DW') crossMult *= 2;
          if (b == 'TW') crossMult *= 3;
          
          crossScore += val;
        } else {
          if (board[current] == null) break;
          crossWord += board[current]!.letter;
          crossScore += board[current]!.value;
        }
        current += perpStep;
      }

      if (crossWord.length > 1) {
        if (!_dictionaryService.isValid(crossWord)) {
          draftError = "'$crossWord' is not in the dictionary."; return false;
        }
        crossTotal += (crossScore * crossMult);
      }
    }

    // Lock Tiles
    for (int i = 0; i < upperWord.length; i++) {
      int pos = startIndex + (i * step);
      if (newIndices.contains(pos)) {
         int letterVal = tileValues[upperWord[i]] ?? 0;
         board[pos] = Tile(letter: upperWord[i], value: letterVal, bonus: getBonus(pos), isLocked: true);
      }
    }

    int bingoBonus = newIndices.length >= 7 ? 50 : 0; 
    players[currentPlayerIndex].score += (mainScore + crossTotal + bingoBonus);
    skipTurn(); 
    return true;
  }
}