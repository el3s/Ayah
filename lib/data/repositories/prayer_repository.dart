import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';

class PrayerTimesModel {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  final String hijriDate;
  final String gregorianDate;

  PrayerTimesModel({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.hijriDate,
    required this.gregorianDate,
  });

  factory PrayerTimesModel.fromJson(Map<String, dynamic> json) {
    final timings = json['data']['timings'];
    final date = json['data']['date'];
    return PrayerTimesModel(
      fajr: _clean(timings['Fajr']),
      sunrise: _clean(timings['Sunrise']),
      dhuhr: _clean(timings['Dhuhr']),
      asr: _clean(timings['Asr']),
      maghrib: _clean(timings['Maghrib']),
      isha: _clean(timings['Isha']),
      hijriDate:
          '${date['hijri']['day']} ${date['hijri']['month']['ar']} ${date['hijri']['year']}',
      gregorianDate: date['gregorian']['date'],
    );
  }

  static String _clean(String raw) => raw.split(' ').first; // إزالة (GMT+1)

  /// لائحة كل الصلوات مع أوقاتها، مرتبة، جاهزة لجدولة الأذان
  List<MapEntry<String, String>> get asOrderedList => [
        MapEntry(AppConstants.prayerNamesAr[0], fajr),
        MapEntry(AppConstants.prayerNamesAr[1], sunrise),
        MapEntry(AppConstants.prayerNamesAr[2], dhuhr),
        MapEntry(AppConstants.prayerNamesAr[3], asr),
        MapEntry(AppConstants.prayerNamesAr[4], maghrib),
        MapEntry(AppConstants.prayerNamesAr[5], isha),
      ];
}

class PrayerRepository {
  /// جيب أوقات الصلاة اليوم بناءً على الإحداثيات (خط العرض/الطول)
  Future<PrayerTimesModel> getPrayerTimesByCoordinates({
    required double lat,
    required double lng,
    int method = AppConstants.defaultCalculationMethod,
  }) async {
    final now = DateTime.now();
    final dateStr = '${now.day}-${now.month}-${now.year}';

    final url = Uri.parse(
      '${AppConstants.prayerTimesBaseUrl}/timings/$dateStr'
      '?latitude=$lat&longitude=$lng&method=$method',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      return PrayerTimesModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('تعذر جلب أوقات الصلاة');
    }
  }

  /// جيب أوقات صلاة شهر كامل مرة وحدة (يستعمل باش نجدولو الأذان لـ 30 يوم
  /// قدام، بلا ما نحتاجو الأنترنت كل يوم)
  Future<List<PrayerTimesModel>> getMonthlyTimings({
    required double lat,
    required double lng,
    int method = AppConstants.defaultCalculationMethod,
  }) async {
    final now = DateTime.now();
    final url = Uri.parse(
      '${AppConstants.prayerTimesBaseUrl}/calendar'
      '?latitude=$lat&longitude=$lng&method=$method'
      '&month=${now.month}&year=${now.year}',
    );

    final response = await http.get(url).timeout(const Duration(seconds: 15));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data
          .map((day) => PrayerTimesModel.fromJson({'data': day}))
          .toList();
    } else {
      throw Exception('تعذر جلب أوقات الصلاة الشهرية');
    }
  }
}
