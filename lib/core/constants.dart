/// ثوابت عامة تستخدم عبر التطبيق كامل
class AppConstants {
  AppConstants._();

  // ---------- روايات القرآن ----------
  static const String riwayaWarsh = 'warsh';
  static const String riwayaHafs = 'hafs';

  // ---------- API تفسير الجلالين ----------
  // مصدر مجاني ومفتوح: https://github.com/Quran-Tafseer/tafseer_api
  static const String tafsirBaseUrl = 'http://api.quran-tafseer.com';
  static const int tafsirJalalaynId = 2;

  // ---------- API أوقات الصلاة ----------
  // مصدر مجاني بالكامل: https://aladhan.com/prayer-times-api
  static const String prayerTimesBaseUrl = 'https://api.aladhan.com/v1';
  // طريقة الحساب: 3 = رابطة العالم الإسلامي (منتشرة فالمغرب والعالم العربي)
  // يمكن للمستخدم تغييرها من الإعدادات (21 = المغرب رسميًا إذا توفرت)
  static const int defaultCalculationMethod = 21; // وزارة الأوقاف المغربية

  // ---------- أسماء جداول قاعدة البيانات ----------
  static const String dbName = 'quran_app.db';
  static const int dbVersion = 1;

  static const String tableWarsh = 'warsh_ayat';
  static const String tableHafs = 'hafs_ayat';
  static const String tableTafsirCache = 'tafsir_cache';
  static const String tableBookmarks = 'bookmarks';
  static const String tableLastRead = 'last_read';
  static const String tableReadingStats = 'reading_stats';

  // ---------- مفاتيح SharedPreferences ----------
  static const String prefRiwaya = 'selected_riwaya';
  static const String prefTheme = 'app_theme_mode';
  static const String prefFontSize = 'quran_font_size';
  static const String prefAdhanEnabled = 'adhan_enabled';
  static const String prefAdhanSound = 'adhan_sound';
  static const String prefLat = 'user_latitude';
  static const String prefLng = 'user_longitude';
  static const String prefCity = 'user_city';
  static const String prefCalcMethod = 'calc_method';
  static const String prefFirstLaunch = 'is_first_launch';
  static const String prefReciter = 'selected_reciter';

  // ---------- أسماء الصلوات بالعربية ----------
  static const List<String> prayerNamesAr = [
    'الفجر',
    'الشروق',
    'الظهر',
    'العصر',
    'المغرب',
    'العشاء',
  ];

  // ---------- قراء التلاوة (CDN مجاني - everyayah.com / mp3quran.net) ----------
  static const Map<String, String> reciters = {
    'ar.alafasy': 'مشاري العفاسي',
    'ar.husary': 'محمود خليل الحصري',
    'ar.minshawi': 'محمد صديق المنشاوي',
    'ar.abdulbasit': 'عبد الباسط عبد الصمد',
    'ar.sudais': 'عبد الرحمن السديس',
  };
}
