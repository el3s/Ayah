import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../data/models/ayah_model.dart';
import '../providers/quran_provider.dart';

/// وضع الحفظ: كيبين الآية، وملي يضغط المستخدم "اختبرني" كيخبي بعض
/// الكلمات عشوائيًا باش يحاول يكملها من الذاكرة - ميزة تميز التطبيق
class MemorizeScreen extends StatefulWidget {
  final int suraNo;
  const MemorizeScreen({super.key, required this.suraNo});

  @override
  State<MemorizeScreen> createState() => _MemorizeScreenState();
}

class _MemorizeScreenState extends State<MemorizeScreen> {
  List<AyahModel> _ayat = [];
  int _currentIndex = 0;
  bool _hidden = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final ayat = await context.read<QuranProvider>().getSurah(widget.suraNo);
    setState(() {
      _ayat = ayat;
      _loading = false;
    });
  }

  String _maskText(String text) {
    // كنخبيو كلمة من كل 3 كلمات (نمط بسيط وفعال للمراجعة)
    final words = text.split(' ');
    return words.asMap().entries.map((e) {
      if (e.key % 3 == 1) return '••••';
      return e.value;
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final ayah = _ayat[_currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text('وضع الحفظ - ${ayah.suraNameAr}')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('آية ${_currentIndex + 1} من ${_ayat.length}',
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Text(
                  _hidden ? _maskText(ayah.ayaText) : ayah.ayaText,
                  textAlign: TextAlign.center,
                  style: AppTheme.quranTextStyle(
                    isDark: Theme.of(context).brightness == Brightness.dark,
                    fontSize: quranProvider.fontSize,
                    isWarsh: quranProvider.isWarsh,
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => setState(() => _hidden = !_hidden),
                    icon: Icon(_hidden ? Icons.visibility : Icons.psychology_rounded),
                    label: Text(_hidden ? 'إظهار الآية' : 'اختبرني'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _currentIndex < _ayat.length - 1
                        ? () => setState(() {
                              _currentIndex++;
                              _hidden = false;
                            })
                        : null,
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('الآية التالية'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
