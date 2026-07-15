import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/ayah_model.dart';
import '../../core/constants.dart';

class QuranRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  String _tableFor(String riwaya) =>
      riwaya == AppConstants.riwayaWarsh
          ? AppConstants.tableWarsh
          : AppConstants.tableHafs;

  /// جيب كل آيات سورة معينة برواية معينة، مرتبة برقم الآية
  Future<List<AyahModel>> getSurah(int suraNo, String riwaya) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _tableFor(riwaya),
      where: 'sura_no = ?',
      whereArgs: [suraNo],
      orderBy: 'aya_no ASC',
    );
    return rows.map((r) => AyahModel.fromDb(r)).toList();
  }

  /// جيب آية واحدة بالضبط (تستعمل فالتفسير وآخر قراءة)
  Future<AyahModel?> getAyah(int suraNo, int ayaNo, String riwaya) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _tableFor(riwaya),
      where: 'sura_no = ? AND aya_no = ?',
      whereArgs: [suraNo, ayaNo],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AyahModel.fromDb(rows.first);
  }

  /// جيب آيات صفحة معينة (لعرض المصحف صفحة بصفحة، ستايل الرسم العثماني)
  Future<List<AyahModel>> getPage(String page, String riwaya) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _tableFor(riwaya),
      where: 'page = ?',
      whereArgs: [page],
      orderBy: 'id ASC',
    );
    return rows.map((r) => AyahModel.fromDb(r)).toList();
  }

  /// فهرس جميع السور (114 سورة) مع عدد آياتها - يبنى مرة وحدة من الجدول
  Future<List<SurahInfo>> getSurahIndex(String riwaya) async {
    final db = await _dbHelper.database;
    final rows = await db.rawQuery('''
      SELECT sura_no, sura_name_ar, sura_name_en, COUNT(*) as total
      FROM ${_tableFor(riwaya)}
      GROUP BY sura_no
      ORDER BY sura_no ASC
    ''');
    return rows
        .map((r) => SurahInfo(
              number: r['sura_no'] as int,
              nameAr: r['sura_name_ar'] as String,
              nameEn: r['sura_name_en'] as String,
              totalAyat: r['total'] as int,
            ))
        .toList();
  }

  /// البحث الكامل فنص القرآن (يشتغل بجوج الروايتين)
  Future<List<AyahModel>> searchQuran(String query, String riwaya) async {
    if (query.trim().isEmpty) return [];
    final db = await _dbHelper.database;
    final ftsTable = riwaya == AppConstants.riwayaWarsh
        ? 'warsh_text_fts'
        : 'hafs_text_fts';
    final mainTable = _tableFor(riwaya);

    // بحث مبسط بـ LIKE (يشتغل مزيان مع النص العربي المشكل خصوصا)
    final rows = await db.rawQuery('''
      SELECT m.* FROM $mainTable m
      WHERE m.aya_text LIKE ?
      ${riwaya == AppConstants.riwayaHafs ? 'OR m.aya_text_emlaey LIKE ?' : ''}
      ORDER BY m.id ASC
      LIMIT 100
    ''', riwaya == AppConstants.riwayaHafs
        ? ['%$query%', '%$query%']
        : ['%$query%']);

    return rows.map((r) => AyahModel.fromDb(r)).toList();
  }

  /// جيب جميع آيات جزء معين (للقراءة اليومية / الورد)
  Future<List<AyahModel>> getJozz(int jozzNo, String riwaya) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      _tableFor(riwaya),
      where: 'jozz = ?',
      whereArgs: [jozzNo],
      orderBy: 'id ASC',
    );
    return rows.map((r) => AyahModel.fromDb(r)).toList();
  }

  /// عدد الصفحات الكلي (لمعرفة آخر صفحة ديال كل رواية)
  Future<int> getTotalPages(String riwaya) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT COUNT(DISTINCT page) as c FROM ${_tableFor(riwaya)}',
    );
    return Sqflite.firstIntValue(result) ?? 604;
  }
}
