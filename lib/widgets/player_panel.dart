import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';

class PlayerPanel extends StatelessWidget {
  const PlayerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>(); 
    
    if (provider.players.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Press "New Game" below.', style: TextStyle(fontSize: 16)),
      );
    }

    String minutes = (provider.timeLeft ~/ 60).toString().padLeft(2, '0');
    String seconds = (provider.timeLeft % 60).toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: Colors.green[800],
      child: Column(
        children: [
          if (provider.useTimer)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                '$minutes:$seconds',
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: provider.players.asMap().entries.map((entry) {
              final index = entry.key;
              final player = entry.value;
              final isActive = index == provider.currentPlayerIndex;

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.amber[300] : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isActive ? Colors.amber : Colors.transparent),
                ),
                child: Column(
                  children: [
                    Text(
                      player.name,
                      style: TextStyle(
                        color: isActive ? Colors.black87 : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${player.score}',
                      style: TextStyle(
                        color: isActive ? Colors.black : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}