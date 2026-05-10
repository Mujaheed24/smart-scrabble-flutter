import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/tile.dart';

class BoardSquare extends StatelessWidget {
  final Tile? tile;
  final int index;

  const BoardSquare({super.key, this.tile, required this.index});

  Color _getColor(String bonus, BuildContext context, bool isSelected) {
    if (isSelected && tile == null) return Colors.green[200]!; // Highlight active cursor
    if (tile != null) return Colors.amber[200]!;
    if (index == 112) return Colors.pink[300]!; 
    switch (bonus) {
      case 'TW': return Colors.red[400]!;
      case 'DW': return Colors.pink[200]!;
      case 'TL': return Colors.blue[600]!;
      case 'DL': return Colors.lightBlue[300]!;
      default: return Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : Colors.grey[300]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    // watch() ensures the square rebuilds instantly as you type
    final provider = context.watch<GameProvider>(); 
    final bonus = provider.getBonus(index);
    
    bool isCursor = provider.selectedSquare == index;
    String? draftChar;

    // Check if this square is along the draft path and should display a typed letter
    if (provider.selectedSquare != null && provider.draftWord.isNotEmpty) {
      int start = provider.selectedSquare!;
      int delta = provider.isDraftHorizontal ? 1 : 15;
      
      for (int i = 0; i < provider.draftWord.length; i++) {
        if (start + (i * delta) == index) {
          draftChar = provider.draftWord[i].toUpperCase();
          break;
        }
      }
    }
    
    return InkWell(
      onTap: () => provider.selectSquare(index),
      child: Container(
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: _getColor(bonus, context, isCursor),
          border: isCursor ? Border.all(color: Colors.green[800]!, width: 2) : null,
        ),
        child: Center(
          child: _buildContent(context, bonus, isCursor, provider.isDraftHorizontal, draftChar),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, String bonus, bool isCursor, bool isHorizontal, String? draftChar) {
    if (tile != null) {
      // 1. Locked Tile (Already on board)
      return Text(tile!.letter, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black));
    } else if (draftChar != null) {
      // 2. Drafted Letter (Ghost typing)
      return Text(draftChar, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green[800]));
    } else if (isCursor) {
      // 3. Selection Cursor (Directional Arrow)
      return Icon(isHorizontal ? Icons.arrow_forward : Icons.arrow_downward, size: 16, color: Colors.green[900]);
    } else {
      // 4. Empty Board Square / Bonus Text
      return Text(
        index == 112 ? '★' : bonus,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 9,
          color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : Colors.black54,
        ),
      );
    }
  }
}