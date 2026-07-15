import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/location_service.dart';
import '../services/adhan_service.dart';
import '../core/constants.dart';

class SettingsProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();
  final AdhanService _adhanService = AdhanService();

  ThemeMode _themeMode = ThemeMode.light;
  bool _adhanEnabled = false;
  String _selectedAdhanSound = 'adhan_makkah';
  String _cityName = '';
  double? _lat;
  double? _lng;
  bool _locationLoading = false;
  String? _locationError;

  ThemeMode get themeMode => _themeMode;
  bool get adhanEnabled => _adhanEnabled;
  String get selectedAdhanSound => _selectedAdhanSound;
  String get cityName => _cityName;
  bool get hasLocation => _lat != null && _lng != null;
  double? get lat => _lat;
  double? get lng => _lng;
  bool get locationLoading => _locationLoading;
  String? get locationError => _locationError;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final themeStr = prefs.getString(AppConstants.prefTheme) ?? 'light';
    _themeMode = themeStr == 'dark' ? ThemeMode.dark : ThemeMode.light;
    _adhanEnabled = prefs.getBool(AppConstants.prefAdhanEnabled) ?? false;
    _selectedAdhanSound =
        prefs.getString(AppConstants.prefAdhanSound) ?? 'adhan_makkah';
    _cityName = prefs.getString(AppConstants.prefCity) ?? '';
    _lat = prefs.getDouble(AppConstants.prefLat);
    _lng = prefs.getDouble(AppConstants.prefLng);

    await _adhanService.init();
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefTheme, isDark ? 'dark' : 'light');
    notifyListeners();
  }

  /// السلسلة الكاملة: طلب الصلاحية -> جيب الموقع -> فعّل الأذان التلقائي
  Future<bool> enableAutoAdhan() async {
    _locationLoading = true;
    _locationError = null;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) {
        _locationError = 'تعذر تحديد الموقع';
        _locationLoading = false;
        notifyListeners();
        return false;
      }

      _lat = position.latitude;
      _lng = position.longitude;
      _cityName = await _locationService.getCityName(_lat!, _lng!);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(AppConstants.prefLat, _lat!);
      await prefs.setDouble(AppConstants.prefLng, _lng!);
      await prefs.setString(AppConstants.prefCity, _cityName);

      await _adhanService.scheduleMonthlyAdhan(lat: _lat!, lng: _lng!);
      await _adhanService.setAdhanEnabled(true);
      _adhanEnabled = true;

      _locationLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _locationError = e.toString();
      _locationLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> disableAutoAdhan() async {
    await _adhanService.setAdhanEnabled(false);
    _adhanEnabled = false;
    notifyListeners();
  }

  Future<void> changeAdhanSound(String soundFile) async {
    _selectedAdhanSound = soundFile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefAdhanSound, soundFile);
    notifyListeners();
  }

  /// تحديث الجدولة الشهرية (تتنادى تلقائيًا مرة فالشهر عبر WorkManager
  /// أو يدويًا من المستخدم)
  Future<void> refreshAdhanSchedule() async {
    if (_lat != null && _lng != null && _adhanEnabled) {
      await _adhanService.scheduleMonthlyAdhan(lat: _lat!, lng: _lng!);
    }
  }
}
