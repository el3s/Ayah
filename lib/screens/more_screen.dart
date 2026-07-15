import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/prayer_provider.dart';
import 'tasbih_screen.dart';
import 'qibla_screen.dart';
import 'azkar_screen.dart';

class MoreScreen extends StatelessWidget {
  final bool embedded;
  const MoreScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('المزيد')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('الميزات الدينية'),
          _buildTile(context, Icons.fingerprint_rounded, 'المسبحة الإلكترونية',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TasbihScreen()))),
          _buildTile(context, Icons.explore_rounded, 'اتجاه القبلة',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaScreen()))),
          _buildTile(context, Icons.wb_sunny_rounded, 'الأذكار اليومية',
              () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AzkarScreen()))),
          const SizedBox(height: 20),
          _sectionTitle('الإعدادات'),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.dark_mode_rounded, color: AppColors.primary),
              title: const Text('الوضع الليلي'),
              value: settings.themeMode == ThemeMode.dark,
              onChanged: (v) => settings.toggleTheme(v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Padding(
        padding: const EdgeInsets.only(bottom: 10, right: 4),
        child: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
      );

  Widget _buildTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppColors.gold),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.chevron_left_rounded),
        onTap: onTap,
      ),
    );
  }
}
