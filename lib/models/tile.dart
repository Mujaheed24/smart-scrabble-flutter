class Tile {
  final String letter;
  final int value;
  final String? bonus;
  bool isLocked;

  Tile({required this.letter, required this.value, this.bonus, this.isLocked = false});

  Map<String, dynamic> toMap() => {
    'letter': letter, 'value': value, 'bonus': bonus, 'isLocked': isLocked
  };

  static Tile fromMap(Map map) => Tile(
    letter: map['letter'], value: map['value'], 
    bonus: map['bonus'], isLocked: map['isLocked']
  );
}