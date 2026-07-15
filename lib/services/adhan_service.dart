import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;
import '../data/repositories/prayer_repository.dart';
import '../core/constants.dart';

/// ⚠️ هام: هاد الدالة خاصها تبقى top-level (برا الكلاس) باش تخدم
/// مع AlarmManager فالخلفية حتى ملي التطبيق مقتول بالكامل.
@pragma('vm:entry-point')
void adhanAlarmCallback(int prayerIndex) async {
  final player = AudioPlayer();
  final prefs = await SharedPreferences.getInstance();
  final soundFile = prefs.getString(AppConstants.prefAdhanSound) ?? 'adhan_makkah';

  try {
    // تشغيل صوت الأذان الكامل (ملف مرفق فالتطبيق: assets/sounds/)
    await player.setAsset('assets/sounds/$soundFile.mp3');
    await player.setVolume(1.0);
    await player.play();
  } catch (e) {
    // إذا تعذر تشغيل الصوت، على الأقل نبعثو إشعار
  }

  // إشعار مرافق يبين اسم الصلاة
  final notifications = FlutterLocalNotificationsPlugin();
  const androidDetails = AndroidNotificationDetails(
    'adhan_channel',
    'تنبيهات الأذان',
    channelDescription: 'إشعار تلقائي عند دخول وقت كل صلاة',
    importance: Importance.max,
    priority: Priority.high,
    playSound: false, // الصوت كنشغلوه يدويًا فوق (أذان كامل)
    fullScreenIntent: true,
  );
  await notifications.show(
    100 + prayerIndex,
    'حان الآن وقت صلاة ${AppConstants.prayerNamesAr[prayerIndex]}',
    'الله أكبر الله أكبر',
    const NotificationDetails(android: androidDetails),
  );

  // كنخليو الصوت يكمل قبل ما نسكرو (تقريبًا 3 دقايق كافية لأغلب الأذانات)
  await Future.delayed(const Duration(minutes: 3));
  await player.dispose();
}

class AdhanService {
  final PrayerRepository _prayerRepository = PrayerRepository();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tzdata.initializeTimeZones();
    await AndroidAlarmManager.initialize();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);
    await _notifications.initialize(initSettings);
  }

  /// كيجدول الأذان التلقائي لـ 30 يوم قدام دفعة وحدة (بلا ما يحتاج
  /// أنترنت كل يوم من بعد). كيتنادى من الإعدادات أو أول مرة كيدير المستخدم
  /// السماح بالموقع.
  Future<void> scheduleMonthlyAdhan({
    required double lat,
    required double lng,
  }) async {
    // نلغيو التنبيهات القديمة قبل ما نزيدو الجداد (تفادي التكرار)
    await cancelAllAdhan();

    final prefs = await SharedPreferences.getInstance();
    final method =
        prefs.getInt(AppConstants.prefCalcMethod) ??
            AppConstants.defaultCalculationMethod;

    final monthlyTimings = await _prayerRepository.getMonthlyTimings(
      lat: lat,
      lng: lng,
      method: method,
    );

    final now = DateTime.now();

    for (int dayOffset = 0; dayOffset < monthlyTimings.length; dayOffset++) {
      final dayTimings = monthlyTimings[dayOffset];
      final date = DateTime(now.year, now.month, dayOffset + 1);

      // كل يوم فيه 5 صلوات (كنخليو الشروق برا الأذان، غير تذكير)
      final prayerTimesOfDay = [
        dayTimings.fajr,
        dayTimings.dhuhr,
        dayTimings.asr,
        dayTimings.maghrib,
        dayTimings.isha,
      ];
      const prayerIndexMap = [0, 2, 3, 4, 5]; // مطابق لـ prayerNamesAr

      for (int i = 0; i < prayerTimesOfDay.length; i++) {
        final timeParts = prayerTimesOfDay[i].split(':');
        final scheduledTime = DateTime(
          date.year,
          date.month,
          date.day,
          int.parse(timeParts[0]),
          int.parse(timeParts[1]),
        );

        // كنبرمجو غير الأوقات لي مازال جاية (ماضية = نتخطاوها)
        if (scheduledTime.isAfter(now)) {
          final alarmId = dayOffset * 10 + prayerIndexMap[i];
          await AndroidAlarmManager.oneShotAt(
            scheduledTime,
            alarmId,
            adhanAlarmCallback,
            exact: true,
            wakeup: true,
            rescheduleOnReboot: true,
            params: {'prayerIndex': prayerIndexMap[i]},
          );
        }
      }
    }
  }

  Future<void> cancelAllAdhan() async {
    // كنلغيو كل alarm IDs المحتملة (30 يوم × 6 صلوات كحد أقصى)
    for (int day = 0; day < 31; day++) {
      for (int prayer = 0; prayer < 6; prayer++) {
        await AndroidAlarmManager.cancel(day * 10 + prayer);
      }
    }
  }

  /// تفعيل/تعطيل الأذان بشكل عام من الإعدادات
  Future<void> setAdhanEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefAdhanEnabled, enabled);
    if (!enabled) {
      await cancelAllAdhan();
    }
  }
}
