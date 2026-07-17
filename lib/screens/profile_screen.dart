import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:donstep/config/theme.dart';
import 'package:donstep/providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: DonStepColors.lime.withOpacity(0.2),
              child: const Icon(Icons.person, size: 50, color: DonStepColors.lime),
            ),
            const SizedBox(height: 16),
            Text(user?.displayName ?? 'Пользователь',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 32),
            Card(
              child: Column(
                children: [
                  _menuItem(Icons.settings, 'Настройки', () {}),
                  const Divider(height: 1, color: DonStepColors.darkGray),
                  _menuItem(Icons.info_outline, 'О приложении', () {}),
                  const Divider(height: 1, color: DonStepColors.darkGray),
                  _menuItem(Icons.logout, 'Выйти', () => auth.logout(), danger: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, VoidCallback onTap, {bool danger = false}) {
    return ListTile(
      leading: Icon(icon, color: danger ? Colors.red : DonStepColors.lime),
      title: Text(label, style: TextStyle(color: danger ? Colors.red : DonStepColors.white)),
      trailing: const Icon(Icons.chevron_right, color: DonStepColors.mediumGray),
      onTap: onTap,
    );
  }
}
