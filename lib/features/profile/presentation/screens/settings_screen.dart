import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle app theme'),
            value: themeMode == ThemeMode.dark,
            onChanged: (v) {
              ref.read(themeModeProvider.notifier).state =
                  v ? ThemeMode.dark : ThemeMode.light;
            },
          ),
          const ListTile(
            title: Text('Language'),
            subtitle: Text('English'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            title: Text('Notifications'),
            subtitle: Text('Push & email preferences'),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            title: Text('Privacy Policy'),
            trailing: Icon(Icons.open_in_new, size: 18),
          ),
          const ListTile(
            title: Text('Terms of Service'),
            trailing: Icon(Icons.open_in_new, size: 18),
          ),
          const Divider(),
          const ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0'),
          ),
        ],
      ),
    );
  }
}
