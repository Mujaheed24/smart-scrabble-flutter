import 'package:flutter/material.dart';

class NewGameDialog extends StatefulWidget {
  const NewGameDialog({super.key});

  @override
  State<NewGameDialog> createState() => _NewGameDialogState();
}

class _NewGameDialogState extends State<NewGameDialog> {
  final List<TextEditingController> _controllers = [
    TextEditingController(text: 'Player 1'),
    TextEditingController(text: 'Player 2'),
  ];
  bool _useTimer = true;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Game Setup'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(_controllers.length, (index) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: TextField(
                controller: _controllers[index],
                decoration: InputDecoration(
                  labelText: 'Player ${index + 1} Name',
                  border: const OutlineInputBorder(),
                ),
              ),
            )),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (_controllers.length > 2)
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () => setState(() => _controllers.removeLast()),
                  ),
                if (_controllers.length < 4)
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: () => setState(() => _controllers.add(
                      TextEditingController(text: 'Player ${_controllers.length + 1}')
                    )),
                  ),
              ],
            ),
            SwitchListTile(
              title: const Text('Enable Turn Timer'),
              value: _useTimer,
              onChanged: (val) => setState(() => _useTimer = val),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            List<String> names = _controllers.map((c) => c.text).toList();
            Navigator.pop(context, {'names': names, 'timer': _useTimer});
          },
          child: const Text('Start Game'),
        ),
      ],
    );
  }
}