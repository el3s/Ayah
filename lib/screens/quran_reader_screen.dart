import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:just_audio/just_audio.dart';
import '../core/theme.dart';
import '../data/models/ayah_model.dart';
import '../data/repositories/tafsir_repository.dart';
import '../providers/quran_provider.dart';

class QuranReaderScreen extends StatefulWidget {
  final int suraNo;
  final int? scrollToAya;

  const QuranReaderScreen({super.key, required this.suraNo, this.scrollToAya});

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  final TafsirRepository _tafsirRepository = TafsirRepository();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<AyahModel> _ayat = [];
  bool _loading = true;
  int? _playingAyaNo;

  @override
  void initState() {
    super.initState();
    _loadSurah();
  }

  Future<void> _loadSurah() async {
    final quranProvider = context.read<QuranProvider>();
    final ayat = await quranProvider.getSurah(widget.suraNo);
    setState(() {
      _ayat = ayat;
      _loading = false;
    });

    if (ayat.isNotEmpty) {
      quranProvider.saveLastRead(
        widget.suraNo,
        widget.scrollToAya ?? ayat.first.ayaNo,
        ayat.first.suraNameAr,
        ayat.first.page,
      );
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  /// عرض التفسير فـ bottom sheet (تصميم عصري وأنيق)
  void _showTafsir(AyahModel ayah) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.book_rounded, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Text('تفسير الجلالين - آية ${ayah.ayaNo}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const Divider(height: 24),
              Expanded(
                child: FutureBuilder<String>(
                  future: _tafsirRepository.getTafsir(ayah.suraNo, ayah.ayaNo),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SingleChildScrollView(
                      controller: scrollController,
                      child: Text(
                        snapshot.data!,
                        style: const TextStyle(fontSize: 16, height: 1.8),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _playAyah(AyahModel ayah) async {
    // تشغيل التلاوة الصوتية للآية عبر CDN مجاني (everyayah.com)
    setState(() => _playingAyaNo = ayah.ayaNo);
    final suraStr = ayah.suraNo.toString().padLeft(3, '0');
    final ayaStr = ayah.ayaNo.toString().padLeft(3, '0');
    final url =
        'https://everyayah.com/data/Alafasy_128kbps/$suraStr$ayaStr.mp3';
    try {
      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر تشغيل الصوت، تحقق من الأنترنت')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final quranProvider = context.watch<QuranProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_ayat.isNotEmpty ? _ayat.first.suraNameAr : ''),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_increase_rounded),
            onPressed: () =>
                quranProvider.setFontSize(quranProvider.fontSize + 2),
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease_rounded),
            onPressed: () =>
                quranProvider.setFontSize(quranProvider.fontSize - 2),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _ayat.length,
              itemBuilder: (context, index) {
                final ayah = _ayat[index];
                final isPlaying = _playingAyaNo == ayah.ayaNo;

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isPlaying
                        ? AppColors.gold.withOpacity(0.12)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // نص الآية بخط المصحف حسب الرواية
                      RichText(
                        textAlign: TextAlign.justify,
                        text: TextSpan(
                          style: AppTheme.quranTextStyle(
                            isDark: Theme.of(context).brightness == Brightness.dark,
                            fontSize: quranProvider.fontSize,
                            isWarsh: quranProvider.isWarsh,
                          ),
                          children: [
                            TextSpan(text: ayah.ayaText),
                            TextSpan(
                              text: ' ﴿${ayah.ayaNo}﴾ ',
                              style: const TextStyle(color: AppColors.gold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause_circle : Icons.play_circle_outline,
                              color: AppColors.primary,
                            ),
                            onPressed: () => _playAyah(ayah),
                          ),
                          IconButton(
                            icon: const Icon(Icons.menu_book_outlined, color: AppColors.primary),
                            onPressed: () => _showTafsir(ayah),
                          ),
                          IconButton(
                            icon: const Icon(Icons.bookmark_border_rounded, color: AppColors.primary),
                            onPressed: () => quranProvider.toggleBookmark(ayah),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share_outlined, color: AppColors.primary),
                            onPressed: () {}, // share_plus - نص الآية + المرجع
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
