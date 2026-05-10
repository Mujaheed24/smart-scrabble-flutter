import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import 'board_square.dart';

class ScrabbleBoard extends StatelessWidget {
  const ScrabbleBoard({super.key});

  @override
  Widget build(BuildContext context) {
    final gameProvider = Provider.of<GameProvider>(context);

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 225,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 15,
      ),
      itemBuilder: (context, index) {
        return BoardSquare(
          tile: gameProvider.board[index],
          index: index,
        );
      },
    );
  }
}