import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text("Dark Mode"),
            value: themeProvider.isDarkMode,
            onChanged: themeProvider.toggleTheme,
            secondary: const Icon(Icons.dark_mode),
          ),
        ],
      ),
    );
  }
}
