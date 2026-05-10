class Player {
  String name;
  int score;

  Player({required this.name, this.score = 0});

  Map<String, dynamic> toMap() => {'name': name, 'score': score};
  static Player fromMap(Map map) => Player(name: map['name'], score: map['score']);
}