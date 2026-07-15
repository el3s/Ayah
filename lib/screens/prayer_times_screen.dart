import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/prayer_provider.dart';
import '../data/repositories/prayer_repository.dart';

class PrayerTimesScreen extends StatefulWidget {
  final bool embedded;
  const PrayerTimesScreen({super.key, this.embedded = false});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerRepository _prayerRepository = PrayerRepository();
  PrayerTimesModel? _todayTimings;
  bool _loadingTimings = false;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    if (settings.hasLocation && _todayTimings == null && !_loadingTimings) {
      _loadTodayTimings(settings);
    }

    return Scaffold(
      appBar: AppBar(title: const Text('أوقات الصلاة')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!settings.hasLocation) _buildEnableCard(context, settings),
          if (settings.hasLocation) ...[
            _buildLocationHeader(settings),
            const SizedBox(height: 16),
            _buildAdhanToggleCard(context, settings),
            const SizedBox(height: 16),
            if (_loadingTimings)
              const Center(child: CircularProgressIndicator())
            else if (_todayTimings != null)
              _buildTimingsCard(_todayTimings!),
          ],
        ],
      ),
    );
  }

  Future<void> _loadTodayTimings(SettingsProvider settings) async {
    setState(() => _loadingTimings = true);
    try {
      final timings = await _prayerRepository.getPrayerTimesByCoordinates(
        lat: settings.lat!,
        lng: settings.lng!,
      );
      if (mounted) setState(() => _todayTimings = timings);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingTimings = false);
    }
  }

  Widget _buildEnableCard(BuildContext context, SettingsProvider settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.location_on_rounded, color: AppColors.gold, size: 48),
            const SizedBox(height: 16),
            const Text(
              'فعّل الأذان التلقائي',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'سنستعمل موقعك باش نحسبو أوقات الصلاة بدقة وننبهك تلقائيًا بصوت الأذان فوقتها، بلا ما تحتاج تدير شي حاجة',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            if (settings.locationError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  settings.locationError!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: settings.locationLoading
                    ? null
                    : () async {
                        final success = await settings.enableAutoAdhan();
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('تم تفعيل الأذان التلقائي بنجاح ✅')),
                          );
                        }
                      },
                icon: settings.locationLoading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.my_location_rounded),
                label: Text(settings.locationLoading ? 'جاري التحديد...' : 'السماح بالموقع وتفعيل الأذان'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationHeader(SettingsProvider settings) {
    return Row(
      children: [
        const Icon(Icons.location_on, color: AppColors.gold, size: 18),
        const SizedBox(width: 6),
        Expanded(
          child: Text(settings.cityName,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildAdhanToggleCard(BuildContext context, SettingsProvider settings) {
    return Card(
      child: SwitchListTile(
        secondary: const Icon(Icons.volume_up_rounded, color: AppColors.primary),
        title: const Text('الأذان التلقائي', style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('تشغيل صوت الأذان تلقائيًا فوقت كل صلاة'),
        value: settings.adhanEnabled,
        onChanged: (value) async {
          if (value) {
            await settings.enableAutoAdhan();
          } else {
            await settings.disableAutoAdhan();
          }
        },
      ),
    );
  }

  Widget _buildTimingsCard(PrayerTimesModel timings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(timings.hijriDate,
                style: const TextStyle(color: Colors.grey, fontSize: 13)),
            const Divider(height: 24),
            ...timings.asOrderedList.map((entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      Text(entry.value,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
