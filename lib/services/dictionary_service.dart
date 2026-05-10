import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import '../models/trie.dart';

class DictionaryService {
  final Trie trie = Trie();
  
  Future<void> load() async {
    try {
      String data = await rootBundle.loadString('assets/dictionary.txt');
      for (var word in data.split('\n')) {
        if (word.trim().isNotEmpty) trie.insert(word.trim().toUpperCase());
      }
    } catch (e) {
      debugPrint('Error loading dictionary: $e');
    }
  }

  bool isValid(String word) => trie.search(word.toUpperCase());
}