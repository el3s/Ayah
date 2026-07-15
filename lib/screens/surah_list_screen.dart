import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/quran_provider.dart';
import 'quran_reader_screen.dart';

class SurahListScreen extends StatelessWidget {
  final bool embedded;
  const SurahListScreen({super.key, this.embedded = false});

  @override
  Widget build(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('فهرس السور'),
        actions: [_buildRiwayaSwitch(context, quranProvider)],
      ),
      body: quranProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: quranProvider.surahIndex.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final surah = quranProvider.surahIndex[index];
                return Card(
                  margin: EdgeInsets.zero,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: Text(
                        '${surah.number}',
                        style: const TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(surah.nameAr,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('${surah.totalAyat} آية'),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuranReaderScreen(suraNo: surah.number),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildRiwayaSwitch(BuildContext context, QuranProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: PopupMenuButton<String>(
        initialValue: provider.selectedRiwaya,
        onSelected: (value) => provider.switchRiwaya(value),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Text(
                provider.isWarsh ? 'ورش' : 'حفص',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
        itemBuilder: (context) => const [
          PopupMenuItem(value: AppConstants.riwayaHafs, child: Text('رواية حفص عن عاصم')),
          PopupMenuItem(value: AppConstants.riwayaWarsh, child: Text('رواية ورش عن نافع')),
        ],
      ),
    );
  }
}
