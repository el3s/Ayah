/// نموذج يمثل آية واحدة (يشتغل مع ورش وحفص بجوج)
class AyahModel {
  final int id;
  final int jozz;
  final String page;
  final int suraNo;
  final String suraNameEn;
  final String suraNameAr;
  final int lineStart;
  final int lineEnd;
  final int ayaNo;
  final String ayaText;
  final String? ayaTextEmlaey; // متوفر فحفص فقط
  bool isBookmarked;

  AyahModel({
    required this.id,
    required this.jozz,
    required this.page,
    required this.suraNo,
    required this.suraNameEn,
    required this.suraNameAr,
    required this.lineStart,
    required this.lineEnd,
    required this.ayaNo,
    required this.ayaText,
    this.ayaTextEmlaey,
    this.isBookmarked = false,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    return AyahModel(
      id: json['id'] as int,
      jozz: json['jozz'] as int,
      page: json['page'].toString(),
      suraNo: json['sura_no'] as int,
      suraNameEn: json['sura_name_en'] as String,
      suraNameAr: (json['sura_name_ar'] as String).trim(),
      lineStart: json['line_start'] as int,
      lineEnd: json['line_end'] as int,
      ayaNo: json['aya_no'] as int,
      ayaText: json['aya_text'] as String,
      ayaTextEmlaey: json['aya_text_emlaey'] as String?,
    );
  }

  factory AyahModel.fromDb(Map<String, dynamic> row) {
    return AyahModel(
      id: row['id'] as int,
      jozz: row['jozz'] as int,
      page: row['page'].toString(),
      suraNo: row['sura_no'] as int,
      suraNameEn: row['sura_name_en'] as String,
      suraNameAr: row['sura_name_ar'] as String,
      lineStart: row['line_start'] as int,
      lineEnd: row['line_end'] as int,
      ayaNo: row['aya_no'] as int,
      ayaText: row['aya_text'] as String,
      ayaTextEmlaey: row['aya_text_emlaey'] as String?,
      isBookmarked: (row['is_bookmarked'] ?? 0) == 1,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'jozz': jozz,
      'page': page,
      'sura_no': suraNo,
      'sura_name_en': suraNameEn,
      'sura_name_ar': suraNameAr,
      'line_start': lineStart,
      'line_end': lineEnd,
      'aya_no': ayaNo,
      'aya_text': ayaText,
      'aya_text_emlaey': ayaTextEmlaey,
    };
  }

  /// مرجع فريد للآية: يستخدم فالتفسير، العلامات، آخر قراءة
  String get reference => '$suraNo:$ayaNo';
}

/// نموذج مبسط لسورة (للفهرس)
class SurahInfo {
  final int number;
  final String nameAr;
  final String nameEn;
  final int totalAyat;
  final String revelationPlace; // مكية / مدنية (نحسبها لاحقًا)

  SurahInfo({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.totalAyat,
    this.revelationPlace = '',
  });
}
