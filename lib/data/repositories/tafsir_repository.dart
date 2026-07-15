import 'dart:convert';
import 'package:http/http.dart' as http;
import '../database_helper.dart';
import '../../core/constants.dart';

class TafsirRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  /// جيب تفسير الجلالين لآية معينة:
  /// 1. يشوف أولا فالكاش المحلي (سريع، يخدم بلا أنترنت)
  /// 2. إلا ما لقاهش، يطلبو من API ويخزنو للمرة الجاية
  Future<String> getTafsir(int suraNo, int ayaNo) async {
    final db = await _dbHelper.database;

    final cached = await db.query(
      AppConstants.tableTafsirCache,
      where: 'sura_no = ? AND aya_no = ?',
      whereArgs: [suraNo, ayaNo],
      limit: 1,
    );

    if (cached.isNotEmpty) {
      return cached.first['tafsir_text'] as String;
    }

    // ما كاينش فالكاش -> نطلبو من الأنترنت
    try {
      final url = Uri.parse(
        '${AppConstants.tafsirBaseUrl}/tafseer/${AppConstants.tafsirJalalaynId}/$suraNo/$ayaNo',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text = data['text'] as String? ?? 'التفسير غير متوفر لهذه الآية.';

        // نخزنو فالكاش المحلي باش المرة الجاية يبان مباشرة
        await db.insert(
          AppConstants.tableTafsirCache,
          {
            'sura_no': suraNo,
            'aya_no': ayaNo,
            'tafsir_text': text,
            'cached_at': DateTime.now().toIso8601String(),
          },
        );
        return text;
      } else {
        return 'تعذر جلب التفسير حاليًا. تحقق من اتصالك بالأنترنت.';
      }
    } catch (e) {
      return 'التفسير غير متوفر حاليًا بدون اتصال بالأنترنت. سيتم تحميله عند توفر الشبكة.';
    }
  }

  /// تحميل مسبق لتفسير سورة كاملة (اختياري - يستعمل لما يفعل المستخدم
  /// "التحميل للقراءة بدون أنترنت" من الإعدادات)
  Future<void> preloadSurahTafsir(
    int suraNo,
    int totalAyat, {
    void Function(int done, int total)? onProgress,
  }) async {
    for (int i = 1; i <= totalAyat; i++) {
      await getTafsir(suraNo, i);
      onProgress?.call(i, totalAyat);
    }
  }
}
