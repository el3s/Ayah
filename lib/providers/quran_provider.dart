import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/ayah_model.dart';
import '../data/repositories/quran_repository.dart';
import '../data/repositories/user_data_repository.dart';
import '../data/models/bookmark_model.dart';
import '../core/constants.dart';

class QuranProvider extends ChangeNotifier {
  final QuranRepository _repository = QuranRepository();
  final UserDataRepository _userDataRepository = UserDataRepository();

  String _selectedRiwaya = AppConstants.riwayaHafs;
  double _fontSize = 26.0;
  List<SurahInfo> _surahIndex = [];
  bool _isLoading = false;

  String get selectedRiwaya => _selectedRiwaya;
  bool get isWarsh => _selectedRiwaya == AppConstants.riwayaWarsh;
  double get fontSize => _fontSize;
  List<SurahInfo> get surahIndex => _surahIndex;
  bool get isLoading => _isLoading;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedRiwaya =
        prefs.getString(AppConstants.prefRiwaya) ?? AppConstants.riwayaHafs;
    _fontSize = prefs.getDouble(AppConstants.prefFontSize) ?? 26.0;
    await loadSurahIndex();
  }

  Future<void> loadSurahIndex() async {
    _isLoading = true;
    notifyListeners();
    _surahIndex = await _repository.getSurahIndex(_selectedRiwaya);
    _isLoading = false;
    notifyListeners();
  }

  /// التبديل بين رواية ورش وحفص - الميزة الأساسية ديال التطبيق
  Future<void> switchRiwaya(String riwaya) async {
    _selectedRiwaya = riwaya;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefRiwaya, riwaya);
    await loadSurahIndex();
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(AppConstants.prefFontSize, size);
    notifyListeners();
  }

  Future<List<AyahModel>> getSurah(int suraNo) {
    return _repository.getSurah(suraNo, _selectedRiwaya);
  }

  Future<List<AyahModel>> search(String query) {
    return _repository.searchQuran(query, _selectedRiwaya);
  }

  Future<void> saveLastRead(int suraNo, int ayaNo, String suraNameAr, String page) {
    return _userDataRepository.saveLastRead(LastReadModel(
      suraNo: suraNo,
      ayaNo: ayaNo,
      suraNameAr: suraNameAr,
      riwaya: _selectedRiwaya,
      page: page,
      timestamp: DateTime.now(),
    ));
  }

  Future<LastReadModel?> getLastRead() {
    return _userDataRepository.getLastRead(_selectedRiwaya);
  }

  Future<void> toggleBookmark(AyahModel ayah) async {
    final exists = await _userDataRepository.isBookmarked(
        ayah.suraNo, ayah.ayaNo, _selectedRiwaya);
    if (exists) {
      // ملاحظة: فتطبيق حقيقي خاصنا نجيبو الـ id باش نمسحوه، مبسط هنا
      notifyListeners();
      return;
    }
    await _userDataRepository.addBookmark(BookmarkModel(
      id: 0,
      suraNo: ayah.suraNo,
      ayaNo: ayah.ayaNo,
      suraNameAr: ayah.suraNameAr,
      riwaya: _selectedRiwaya,
      createdAt: DateTime.now(),
    ));
    notifyListeners();
  }
}
