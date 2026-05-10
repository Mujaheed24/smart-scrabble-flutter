class TrieNode {
  final Map<String, TrieNode> children = {};
  bool isEndOfWord = false;
}

class Trie {
  final TrieNode root = TrieNode();

  void insert(String word) {
    TrieNode current = root;
    for (int i = 0; i < word.length; i++) {
      current = current.children.putIfAbsent(word[i], () => TrieNode());
    }
    current.isEndOfWord = true;
  }

  bool search(String word) {
    TrieNode current = root;
    for (int i = 0; i < word.length; i++) {
      if (!current.children.containsKey(word[i])) return false;
      current = current.children[word[i]]!;
    }
    return current.isEndOfWord;
  }
}