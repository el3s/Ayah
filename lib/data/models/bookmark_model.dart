class BookmarkModel {
  final int id;
  final int suraNo;
  final int ayaNo;
  final String suraNameAr;
  final String riwaya;
  final String? note;
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.suraNo,
    required this.ayaNo,
    required this.suraNameAr,
    required this.riwaya,
    this.note,
    required this.createdAt,
  });

  factory BookmarkModel.fromDb(Map<String, dynamic> row) {
    return BookmarkModel(
      id: row['id'] as int,
      suraNo: row['sura_no'] as int,
      ayaNo: row['aya_no'] as int,
      suraNameAr: row['sura_name_ar'] as String,
      riwaya: row['riwaya'] as String,
      note: row['note'] as String?,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'sura_no': suraNo,
      'aya_no': ayaNo,
      'sura_name_ar': suraNameAr,
      'riwaya': riwaya,
      'note': note,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class LastReadModel {
  final int suraNo;
  final int ayaNo;
  final String suraNameAr;
  final String riwaya;
  final String page;
  final DateTime timestamp;

  LastReadModel({
    required this.suraNo,
    required this.ayaNo,
    required this.suraNameAr,
    required this.riwaya,
    required this.page,
    required this.timestamp,
  });

  factory LastReadModel.fromDb(Map<String, dynamic> row) {
    return LastReadModel(
      suraNo: row['sura_no'] as int,
      ayaNo: row['aya_no'] as int,
      suraNameAr: row['sura_name_ar'] as String,
      riwaya: row['riwaya'] as String,
      page: row['page'].toString(),
      timestamp: DateTime.parse(row['timestamp'] as String),
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'sura_no': suraNo,
      'aya_no': ayaNo,
      'sura_name_ar': suraNameAr,
      'riwaya': riwaya,
      'page': page,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
