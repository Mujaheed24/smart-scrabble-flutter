import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: context.watch<ThemeProvider>().isDark,
            onChanged: (v) => context.read<ThemeProvider>().toggle(v),
          ),
          ListTile(
            title: const Text('Delete Saved Game', style: TextStyle(color: Colors.red)),
            leading: const Icon(Icons.delete, color: Colors.red),
            onTap: () {
              Hive.box('scrabbleBox').clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Saved game deleted')),
              );
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
}