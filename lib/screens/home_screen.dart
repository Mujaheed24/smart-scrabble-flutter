import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../widgets/scrabble_board.dart';
import '../widgets/player_panel.dart';
import '../widgets/new_game_dialog.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Scrabble', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green[900],
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          )
        ],
      ),
      body: SafeArea( 
        child: Column(
          children: [
            const PlayerPanel(),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: ScrabbleBoard(),
              ),
            ),
            provider.selectedSquare != null 
                ? _buildDraftPanel(context, provider) 
                : _buildStandardButtons(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftPanel(BuildContext context, GameProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          const Text('Use lowercase letters for 0-point blanks', style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              labelText: provider.isDraftHorizontal ? 'Type Across (→)' : 'Type Down (↓)',
              border: const OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.green[700]!, width: 2)),
            ),
            onChanged: (val) => provider.updateDraft(val),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => provider.clearDraft(),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700]),
                  onPressed: () {
                    bool success = provider.commitDraft();
                    if (!success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.draftError, style: const TextStyle(fontWeight: FontWeight.bold)),
                          backgroundColor: Colors.red[800],
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    }
                  },
                  child: const Text('PLAY WORD', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStandardButtons(BuildContext context, GameProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () async {
                  final Map<String, dynamic>? result = await showDialog(
                    context: context,
                    builder: (context) => const NewGameDialog(),
                  );
                  if (result != null && result['names'].isNotEmpty) {
                    provider.startGame(result['names'], enableTimer: result['timer']);
                  }
                },
                child: const Text('New Game'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () => provider.loadGame(),
                child: const Text('Resume', style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[300]),
                onPressed: () => provider.skipTurn(),
                child: const Text('Skip', style: TextStyle(color: Colors.black)),
              ),
              IconButton(
                icon: const Icon(Icons.undo),
                color: Colors.red[400],
                onPressed: provider.matchHistory.isEmpty ? null : () => provider.undo(),
                tooltip: 'Undo Last Move',
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // --- NEW: FINISH GAME BUTTON ---
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[800],
              foregroundColor: Colors.white,
              minimumSize: const Size(200, 40),
            ),
            icon: const Icon(Icons.emoji_events),
            label: const Text('Finish Game & Declare Winner', style: TextStyle(fontWeight: FontWeight.bold)),
            onPressed: provider.players.isEmpty ? null : () => _showWinnerDialog(context, provider),
          ),
          
          const SizedBox(height: 8),
          
          // --- NEW: YOUR DEVELOPER SIGNATURE ---
          const Text(
            'Developed by [Mujaheed Bashir]', // <--- PUT YOUR INITIALS HERE
            style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.2),
          ),
        ],
      ),
    );
  }

  // --- NEW: WINNER DIALOG LOGIC ---
  void _showWinnerDialog(BuildContext context, GameProvider provider) {
    if (provider.players.isEmpty) return;
    
    // Sort players by score to find the highest
    final sorted = List.from(provider.players)..sort((a, b) => b.score.compareTo(a.score));
    bool isTie = sorted.length > 1 && sorted[0].score == sorted[1].score;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(child: Text('🏆 Game Over 🏆', style: TextStyle(fontSize: 28))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isTie ? 'It\'s a Tie!' : '${sorted[0].name} Wins!', 
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)
            ),
            const SizedBox(height: 12),
            Text('Winning Score: ${sorted[0].score}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            // Show the runner ups
            if (sorted.length > 1) ...[
              const Divider(),
              const Text('Final Standings:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...sorted.map((p) => Text('${p.name}: ${p.score}')),
            ]
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog to let them view the final board
            },
            child: const Text('View Final Board', style: TextStyle(fontSize: 16)),
          )
        ],
      ),
    );
  }
}