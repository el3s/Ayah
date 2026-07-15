import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../core/constants.dart';

/// المسؤول عن إنشاء قاعدة البيانات المحلية وتعبئتها من ملفات JSON
/// عند أول تشغيل للتطبيق فقط. باقي الاستخدام يكون من القاعدة مباشرة
/// (أسرع بكثير من قراءة JSON فكل مرة).
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);

    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // جدول آيات ورش
    await db.execute('''
      CREATE TABLE ${AppConstants.tableWarsh} (
        id INTEGER PRIMARY KEY,
        jozz INTEGER,
        page TEXT,
        sura_no INTEGER,
        sura_name_en TEXT,
        sura_name_ar TEXT,
        line_start INTEGER,
        line_end INTEGER,
        aya_no INTEGER,
        aya_text TEXT
      )
    ''');

    // جدول آيات حفص (فيه النص الإملائي الإضافي للبحث)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableHafs} (
        id INTEGER PRIMARY KEY,
        jozz INTEGER,
        page TEXT,
        sura_no INTEGER,
        sura_name_en TEXT,
        sura_name_ar TEXT,
        line_start INTEGER,
        line_end INTEGER,
        aya_no INTEGER,
        aya_text TEXT,
        aya_text_emlaey TEXT
      )
    ''');

    // النصوص العربية نخزنوها بجدول منفصل مفهرس للبحث الكامل (FTS)
    await db.execute('''
      CREATE VIRTUAL TABLE warsh_text_fts USING fts4(
        aya_text
      )
    ''');
    await db.execute('''
      CREATE VIRTUAL TABLE hafs_text_fts USING fts4(
        aya_text
      )
    ''');

    // ذاكرة تخزين التفسير (كاش) باش ما نديروش طلب أنترنت مرتين لنفس الآية
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTafsirCache} (
        sura_no INTEGER,
        aya_no INTEGER,
        tafsir_text TEXT,
        cached_at TEXT,
        PRIMARY KEY (sura_no, aya_no)
      )
    ''');

    // العلامات المرجعية
    await db.execute('''
      CREATE TABLE ${AppConstants.tableBookmarks} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        sura_no INTEGER,
        aya_no INTEGER,
        sura_name_ar TEXT,
        riwaya TEXT,
        note TEXT,
        created_at TEXT
      )
    ''');

    // آخر قراءة (سجل واحد فقط لكل رواية)
    await db.execute('''
      CREATE TABLE ${AppConstants.tableLastRead} (
        riwaya TEXT PRIMARY KEY,
        sura_no INTEGER,
        aya_no INTEGER,
        sura_name_ar TEXT,
        page TEXT,
        timestamp TEXT
      )
    ''');

    // إحصائيات القراءة اليومية
    await db.execute('''
      CREATE TABLE ${AppConstants.tableReadingStats} (
        date TEXT PRIMARY KEY,
        ayat_count INTEGER
      )
    ''');

    await _seedFromAssets(db);
  }

  /// تعبئة القاعدة من ملفات JSON المرفقة فالمشروع (مرة واحدة فقط)
  Future<void> _seedFromAssets(Database db) async {
    final warshRaw = await rootBundle.loadString('assets/data/warsh.json');
    final hafsRaw = await rootBundle.loadString('assets/data/hafs.json');

    final List<dynamic> warshList = jsonDecode(warshRaw);
    final List<dynamic> hafsList = jsonDecode(hafsRaw);

    final batch = db.batch();

    for (final item in warshList) {
      batch.insert(AppConstants.tableWarsh, {
        'id': item['id'],
        'jozz': item['jozz'],
        'page': item['page'].toString(),
        'sura_no': item['sura_no'],
        'sura_name_en': item['sura_name_en'],
        'sura_name_ar': (item['sura_name_ar'] as String).trim(),
        'line_start': item['line_start'],
        'line_end': item['line_end'],
        'aya_no': item['aya_no'],
        'aya_text': item['aya_text'],
      });
      batch.insert('warsh_text_fts', {
        'rowid': item['id'],
        'aya_text': item['aya_text'],
      });
    }

    for (final item in hafsList) {
      batch.insert(AppConstants.tableHafs, {
        'id': item['id'],
        'jozz': item['jozz'],
        'page': item['page'].toString(),
        'sura_no': item['sura_no'],
        'sura_name_en': item['sura_name_en'],
        'sura_name_ar': (item['sura_name_ar'] as String).trim(),
        'line_start': item['line_start'],
        'line_end': item['line_end'],
        'aya_no': item['aya_no'],
        'aya_text': item['aya_text'],
        'aya_text_emlaey': item['aya_text_emlaey'],
      });
      batch.insert('hafs_text_fts', {
        'rowid': item['id'],
        'aya_text': item['aya_text'],
      });
    }

    await batch.commit(noResult: true);
  }
}
