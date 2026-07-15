import 'package:sqflite/sqflite.dart';
import '../database_helper.dart';
import '../models/bookmark_model.dart';
import '../../core/constants.dart';

class UserDataRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // ---------------- العلامات المرجعية ----------------

  Future<int> addBookmark(BookmarkModel bookmark) async {
    final db = await _dbHelper.database;
    return db.insert(AppConstants.tableBookmarks, bookmark.toDbMap());
  }

  Future<void> removeBookmark(int id) async {
    final db = await _dbHelper.database;
    await db.delete(
      AppConstants.tableBookmarks,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<BookmarkModel>> getAllBookmarks() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      AppConstants.tableBookmarks,
      orderBy: 'created_at DESC',
    );
    return rows.map((r) => BookmarkModel.fromDb(r)).toList();
  }

  Future<bool> isBookmarked(int suraNo, int ayaNo, String riwaya) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      AppConstants.tableBookmarks,
      where: 'sura_no = ? AND aya_no = ? AND riwaya = ?',
      whereArgs: [suraNo, ayaNo, riwaya],
    );
    return rows.isNotEmpty;
  }

  // ---------------- آخر قراءة ----------------

  Future<void> saveLastRead(LastReadModel lastRead) async {
    final db = await _dbHelper.database;
    await db.insert(
      AppConstants.tableLastRead,
      {'riwaya': lastRead.riwaya, ...lastRead.toDbMap()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<LastReadModel?> getLastRead(String riwaya) async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      AppConstants.tableLastRead,
      where: 'riwaya = ?',
      whereArgs: [riwaya],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return LastReadModel.fromDb(rows.first);
  }

  // ---------------- إحصائيات القراءة ----------------

  /// يزيد عدد الآيات المقروءة اليوم (يستدعى كل ما فتح المستخدم آية جديدة)
  Future<void> incrementReadingStats(int ayatCount) async {
    final db = await _dbHelper.database;
    final today = DateTime.now().toIso8601String().split('T').first;

    final existing = await db.query(
      AppConstants.tableReadingStats,
      where: 'date = ?',
      whereArgs: [today],
    );

    if (existing.isEmpty) {
      await db.insert(AppConstants.tableReadingStats, {
        'date': today,
        'ayat_count': ayatCount,
      });
    } else {
      final current = existing.first['ayat_count'] as int;
      await db.update(
        AppConstants.tableReadingStats,
        {'ayat_count': current + ayatCount},
        where: 'date = ?',
        whereArgs: [today],
      );
    }
  }

  /// إحصائيات آخر 7 أيام (تستعمل فرسم بياني بسيط فالصفحة الرئيسية)
  Future<Map<String, int>> getLast7DaysStats() async {
    final db = await _dbHelper.database;
    final rows = await db.query(
      AppConstants.tableReadingStats,
      orderBy: 'date DESC',
      limit: 7,
    );
    return {for (final r in rows) r['date'] as String: r['ayat_count'] as int};
  }
}
